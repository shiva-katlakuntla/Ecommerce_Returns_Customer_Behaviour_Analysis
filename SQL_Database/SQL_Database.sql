/* =========================================================
   E-COMMERCE DATA GENERATION SCRIPT - MYSQL 8+
   ShopKart Return & Customer Behavior Analytics
   ========================================================= */

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- TABLES CREATION

-- CREATE CUSTOMERS TABLE 

DROP TABLE IF EXISTS customers;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    gender VARCHAR(20),
    age INT,
    city VARCHAR(50),
    state VARCHAR(50),
    signup_date DATE,
    loyalty_tier VARCHAR(20),
    customer_status VARCHAR(20),
    annual_spend DECIMAL(12,2)
);

-- CREATE PRODUCTS TABLE

DROP TABLE IF EXISTS products;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150),
    category VARCHAR(60),
    sub_category VARCHAR(80),
    brand VARCHAR(80),
    base_price DECIMAL(12,2),
    cost_price DECIMAL(12,2),
    product_rating DECIMAL(3,2),
    return_eligible VARCHAR(10),
    seller_id INT
);

-- CREATE SELLERS TABLE

DROP TABLE IF EXISTS sellers;

CREATE TABLE sellers (
    seller_id INT PRIMARY KEY,
    seller_name VARCHAR(120),
    seller_city VARCHAR(50),
    seller_rating DECIMAL(3,2),
    seller_type VARCHAR(40),
    onboarding_date DATE,
    return_rate_percent DECIMAL(5,2),
    seller_status VARCHAR(30)
);

-- CREATE ORDERS TABLE

DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    customer_id INT,
    order_datetime DATETIME,
    order_status VARCHAR(30),
    order_amount DECIMAL(14,2),
    payment_method VARCHAR(30),
    coupon_used VARCHAR(10),
    delivery_city VARCHAR(50),
    expected_delivery_date DATE,
    actual_delivery_date DATE
);

-- CREATE ORDER_ITEMS TABLE

DROP TABLE IF EXISTS order_items;

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY,
    order_id BIGINT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(12,2),
    discount_amount DECIMAL(12,2),
    item_total DECIMAL(12,2)
);

-- CREATE PAYMENTS TABLE

DROP TABLE IF EXISTS payments;

CREATE TABLE payments (
    payment_id BIGINT,
    order_id BIGINT,
    payment_method VARCHAR(30),
    payment_status VARCHAR(30),
    payment_amount DECIMAL(14,2),
    payment_datetime DATETIME,
    transaction_reference VARCHAR(80)
);

-- CREATE RETURNS TABLE

DROP TABLE IF EXISTS returns;

CREATE TABLE returns (
    return_id BIGINT,
    order_id BIGINT,
    customer_id INT,
    return_reason VARCHAR(100),
    return_request_date DATETIME,
    return_status VARCHAR(30),
    return_pickup_status VARCHAR(30),
    is_suspicious_return BIT(1)
);

-- CREATE REFUNDS TABLE 

DROP TABLE IF EXISTS refunds;

CREATE TABLE refunds (
    refund_id BIGINT,
    return_id BIGINT,
    refund_amount DECIMAL(14,2),
    refund_status VARCHAR(30),
    refund_method VARCHAR(30),
    refund_processed_date DATE,
    refund_reason_code VARCHAR(50)
);

-- CREATE DELIVERY_LOGS TABLE

DROP TABLE IF EXISTS delivery_logs;

CREATE TABLE delivery_logs (
    delivery_id BIGINT,
    order_id BIGINT,
    warehouse_id INT,
    delivery_partner VARCHAR(80),
    dispatch_date DATE,
    delivery_attempts INT,
    delivery_status VARCHAR(30),
    delay_days INT
);

-- CREATE WAREHOUSES TABLE

DROP TABLE IF EXISTS warehouses;

CREATE TABLE warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    region VARCHAR(30),
    capacity_units INT,
    avg_dispatch_time_hours DECIMAL(6,2)
);

-- CREATE REVIEWS TABLE

DROP TABLE IF EXISTS reviews;

CREATE TABLE reviews (
    review_id BIGINT,
    order_id BIGINT,
    customer_id INT,
    product_id INT,
    rating INT,
    review_text VARCHAR(500),
    review_date DATE
);

-- CREATE  CUSTOMER_SUPPORT_TICKETS TABLE

DROP TABLE IF EXISTS customer_support_tickets;

CREATE TABLE customer_support_tickets (
    ticket_id BIGINT PRIMARY KEY,
    customer_id INT,
    order_id BIGINT NULL,
    ticket_category VARCHAR(80),
    ticket_created_date DATETIME,
    resolution_status VARCHAR(30),
    resolution_time_hours INT,
    customer_sentiment VARCHAR(30)
);

