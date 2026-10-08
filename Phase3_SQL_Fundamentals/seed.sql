USE agriconnect;

-- 1. Towns
INSERT INTO towns (town_name, district) VALUES
('Kampala Central','Kampala'),
('Mbale','Mbale'),
('Mbarara','Mbarara'),
('Gulu','Gulu'),
('Jinja','Jinja');


-- 2. Users
INSERT INTO users (full_name, phone, role, town_id) VALUES
('Nakato Sarah','256772100001','BOTH',1),
('Okello John','256772100002','FARMER',2),
('Mwesigwa David','256772100003','FARMER',3),
('Achieng Grace','256772100004','BUYER',1),
('Kato Peter','256772100005','BUYER',5);


-- 3. Wallets
INSERT INTO wallets (user_id, balance)
SELECT user_id, 500000 FROM users;


-- 4. Products
INSERT INTO products
(farmer_id, product_name, category, unit, unit_price, stock_qty)
VALUES
(2,'Matooke Bunch','TUBER','bunch',25000,120),
(2,'Groundnuts','GRAIN','kg',7000,300),
(3,'Matoke Crates','FRUIT','crate',45000,40),
(3,'Fresh Milk','OTHER','litre',1500,500),
(1,'Ndizi Nshaki','FRUIT','bunch',30000,60);


-- 5. Orders
INSERT INTO orders
(buyer_id, status, delivery_address, total_amount)
VALUES
(4,'DELIVERED','Kampala Central',250000),
(5,'DELIVERED','Jinja Town',140000),
(1,'PAID','Kampala Central',90000),
(4,'PENDING','Kampala Central',45000);


-- 6. Order Items
INSERT INTO order_items
(order_id, product_id, qty, unit_price)
VALUES
(1,1,10,25000),
(1,2,20,7000),
(2,2,20,7000),
(3,5,3,30000),
(4,3,1,45000);


-- 7. Deliveries
INSERT INTO deliveries
(order_id, driver_name, status)
VALUES
(1,'Musa Ibrahim','DONE'),
(2,'John Bosco','DONE'),
(3,'Alex Peter','IN_TRANSIT'),
(4,'David Okello','SCHEDULED');


-- 8. Reviews
INSERT INTO reviews
(buyer_id, product_id, rating, comment)
VALUES
(4,1,5,'Fresh and good quality matooke.'),
(5,2,4,'Good quality groundnuts.'),
(1,3,5,'Excellent matoke crates.'),
(4,5,4,'Good quality bananas.');


-- 9. Wallet Transactions
INSERT INTO wallet_txns
(wallet_id, txn_type, amount, ref_code, counterparty_wallet)
VALUES
(4,'PAYMENT',250000,'TXN000001',2),
(2,'RECEIPT',237500,'TXN000002',4),
(5,'PAYMENT',140000,'TXN000003',2),
(2,'RECEIPT',133000,'TXN000004',5),
(1,'CASH_IN',100000,'TXN000005',NULL),
(3,'CASH_OUT',50000,'TXN000006',NULL);