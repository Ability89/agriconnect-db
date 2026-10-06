CREATE TABLE towns (
  town_id INT AUTO_INCREMENT PRIMARY KEY,
  town_name VARCHAR(60) NOT NULL UNIQUE,
  district VARCHAR(60)
);
CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(13) NOT NULL UNIQUE, 
  email VARCHAR(120) UNIQUE,
  role ENUM('FARMER','BUYER','BOTH') NOT NULL DEFAULT 'BUYER',
  town_id INT NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (town_id) REFERENCES towns(town_id)
);
show tables;
CREATE TABLE wallets (
  wallet_id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL UNIQUE,
  balance DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (balance >= 0),
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
CREATE TABLE wallet_txns (
  txn_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  wallet_id INT NOT NULL,
  txn_type ENUM('CASH_IN','CASH_OUT','PAYMENT','RECEIPT') NOT NULL,
  amount DECIMAL(12,2) NOT NULL CHECK (amount > 0),
  ref_code VARCHAR(20) UNIQUE,
  counterparty_wallet INT NULL,
  txn_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (wallet_id) REFERENCES wallets(wallet_id)
);
CREATE TABLE products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  farmer_id INT NOT NULL,
  product_name VARCHAR(100) NOT NULL,
  category ENUM('GRAIN','FRUIT','VEGETABLE','TUBER','LIVESTOCK','OTHER') NOT NULL,
  unit ENUM('kg','crate','bag','bunch','litre') NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price > 0),
  stock_qty DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  is_active BOOLEAN DEFAULT TRUE,
  FOREIGN KEY (farmer_id) REFERENCES users(user_id)
);
CREATE TABLE order_items (
  order_item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  qty DECIMAL(10,2) NOT NULL CHECK (qty > 0),
  unit_price DECIMAL(10,2) NOT NULL,
  line_total DECIMAL(12,2) GENERATED ALWAYS AS (qty * unit_price) STORED,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);
CREATE TABLE deliveries (
  delivery_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL UNIQUE, 
  driver_name VARCHAR(100),
  status ENUM('SCHEDULED','IN_TRANSIT','DONE','FAILED') DEFAULT 'SCHEDULED',
  dispatched_at DATETIME NULL,
  delivered_at DATETIME NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);
CREATE TABLE reviews (
  review_id INT AUTO_INCREMENT PRIMARY KEY,
  buyer_id INT NOT NULL,
  product_id INT NOT NULL,
  rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment VARCHAR(300),
  review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (buyer_id, product_id),
  FOREIGN KEY (buyer_id) REFERENCES users(user_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);