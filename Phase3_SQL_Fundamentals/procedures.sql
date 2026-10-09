
USE agriconnect;

-- =====================================================
-- PROCEDURE 1: PLACE AN ORDER / CHECKOUT
-- Handles payment, stock, farmer proceeds and rollback
-- =====================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_place_order$$

CREATE PROCEDURE sp_place_order(
    IN p_buyer_id INT,
    IN p_product_id INT,
    IN p_qty DECIMAL(10,2),
    IN p_address VARCHAR(200)
)
BEGIN
    DECLARE v_price DECIMAL(10,2);
    DECLARE v_stock DECIMAL(10,2);
    DECLARE v_farmer_id INT;
    DECLARE v_active TINYINT;
    DECLARE v_total DECIMAL(14,2);
    DECLARE v_commission DECIMAL(14,2);
    DECLARE v_farmer_amount DECIMAL(14,2);
    DECLARE v_buyer_wallet INT;
    DECLARE v_farmer_wallet INT;
    DECLARE v_buyer_balance DECIMAL(14,2);
    DECLARE v_order_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Required product or wallet record was not found';
    END;

    IF p_qty IS NULL OR p_qty <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    START TRANSACTION;

    SELECT unit_price, stock_qty, farmer_id, is_active
    INTO v_price, v_stock, v_farmer_id, v_active
    FROM products
    WHERE product_id = p_product_id
    FOR UPDATE;

    IF v_active IS NULL OR v_active <> 1 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Product is not active';
    END IF;

    IF v_stock < p_qty THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient product stock';
    END IF;

    IF p_buyer_id = v_farmer_id THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'A farmer cannot buy their own product';
    END IF;

    SET v_total = ROUND(v_price * p_qty, 2);
    SET v_commission = ROUND(v_total * 0.05, 2);
    SET v_farmer_amount = v_total - v_commission;

    SELECT wallet_id, balance
    INTO v_buyer_wallet, v_buyer_balance
    FROM wallets
    WHERE user_id = p_buyer_id
    FOR UPDATE;

    IF v_buyer_balance < v_total THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient wallet balance';
    END IF;

    SELECT wallet_id
    INTO v_farmer_wallet
    FROM wallets
    WHERE user_id = v_farmer_id
    FOR UPDATE;

    INSERT INTO orders (
        buyer_id, status, delivery_address, total_amount
    )
    VALUES (
        p_buyer_id, 'PAID', p_address, v_total
    );

    SET v_order_id = LAST_INSERT_ID();

    INSERT INTO order_items (
        order_id, product_id, qty, unit_price
    )
    VALUES (
        v_order_id, p_product_id, p_qty, v_price
    );

    UPDATE products
    SET stock_qty = stock_qty - p_qty
    WHERE product_id = p_product_id;

    UPDATE wallets
    SET balance = balance - v_total
    WHERE wallet_id = v_buyer_wallet;

    UPDATE wallets
    SET balance = balance + v_farmer_amount
    WHERE wallet_id = v_farmer_wallet;

    INSERT INTO wallet_txns (
        wallet_id, txn_type, amount, ref_code, counterparty_wallet
    )
    VALUES (
        v_buyer_wallet, 'PAYMENT', v_total,
        CONCAT('O', v_order_id, 'P'), v_farmer_wallet
    );

    INSERT INTO wallet_txns (
        wallet_id, txn_type, amount, ref_code, counterparty_wallet
    )
    VALUES (
        v_farmer_wallet, 'RECEIPT', v_farmer_amount,
        CONCAT('O', v_order_id, 'R'), v_buyer_wallet
    );

    INSERT INTO deliveries (order_id)
    VALUES (v_order_id);

    COMMIT;

    SELECT
        v_order_id AS order_id,
        v_total AS total_amount,
        v_commission AS platform_commission,
        v_farmer_amount AS farmer_receives,
        'Order completed successfully' AS message;
END$$

DROP PROCEDURE IF EXISTS sp_cash_in$$

-- =====================================================
-- PROCEDURE 2: CASH IN
-- Adds funds to a wallet and records the transaction
-- =====================================================

CREATE PROCEDURE sp_cash_in(
    IN p_user_id INT,
    IN p_amt DECIMAL(12,2)
)
BEGIN
    DECLARE v_wallet_id INT;
    DECLARE v_ref_code VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    DECLARE EXIT HANDLER FOR NOT FOUND
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Wallet not found';
    END;

    IF p_amt IS NULL OR p_amt <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cash-in amount must be positive';
    END IF;

    START TRANSACTION;

    SELECT wallet_id
    INTO v_wallet_id
    FROM wallets
    WHERE user_id = p_user_id
    FOR UPDATE;

    SET v_ref_code = CONCAT(
        'CI',
        DATE_FORMAT(NOW(6), '%y%m%d%H%i%s%f')
    );

    UPDATE wallets
    SET balance = balance + p_amt
    WHERE wallet_id = v_wallet_id;

    INSERT INTO wallet_txns (
        wallet_id, txn_type, amount, ref_code
    )
    VALUES (
        v_wallet_id, 'CASH_IN', p_amt, v_ref_code
    );

    COMMIT;

    SELECT
        v_wallet_id AS wallet_id,
        p_amt AS amount_added,
        v_ref_code AS reference_code,
        'Cash-in completed successfully' AS message;
END$$

DELIMITER ;