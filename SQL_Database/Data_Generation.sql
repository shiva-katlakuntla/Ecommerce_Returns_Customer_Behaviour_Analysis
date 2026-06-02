/* =========================================================
   E-COMMERCE DATA GENERATION SCRIPT - MYSQL 8+
   ShopKart Return & Customer Behavior Analytics
   ========================================================= */

CREATE DATABASE IF NOT EXISTS ecommerce_db;
USE ecommerce_db;

-- =========================================================
-- ECOMMERCE DATABASE - CUSTOMERS TABLE + 50,000 RECORDS
-- Includes intentional data quality problems
-- =========================================================
-- HELPER NUMBERS TABLE
-- =========================================================

DROP TABLE IF EXISTS seq_10;
CREATE TABLE seq_10(n INT);

INSERT INTO seq_10 VALUES
(0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

-- =========================================================
-- INSERT 50,000 CUSTOMERS
-- =========================================================

INSERT INTO customers
SELECT
    100001 + row_num AS customer_id,

    -- customer_name with some extra spaces
    CASE
        WHEN RAND() < 0.03 THEN CONCAT('  ', names.first_name, ' ', names.last_name, '  ')
        ELSE CONCAT(names.first_name, ' ', names.last_name)
    END AS customer_name,

    -- inconsistent gender values
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(FLOOR(1 + RAND()*8),
                'M','F','male','female','MALE','FEMALE','Other','other')
        ELSE
            ELT(FLOOR(1 + RAND()*3),
                'Male','Female','Other')
    END AS gender,

    -- age with outliers
    CASE
        WHEN RAND() < 0.01 THEN FLOOR(10 + RAND()*5)
        WHEN RAND() < 0.02 THEN FLOOR(100 + RAND()*10)
        ELSE FLOOR(18 + RAND()*63)
    END AS age,

    -- city inconsistencies
    CASE
        WHEN RAND() < 0.10 THEN
            ELT(FLOOR(1 + RAND()*10),
                'hyderabad','HYDERABAD','Bengaluru','bangalore',
                'Mumbai','mumbai','Delhi','DELHI',
                'Chennai','chennai')
        ELSE
            ELT(FLOOR(1 + RAND()*10),
                'Hyderabad','Bangalore','Mumbai','Delhi',
                'Chennai','Pune','Kolkata','Ahmedabad',
                'Jaipur','Lucknow')
    END AS city,

    -- missing state values
    CASE
        WHEN RAND() < 0.04 THEN NULL
        ELSE
            ELT(FLOOR(1 + RAND()*10),
                'Telangana','Karnataka','Maharashtra',
                'Delhi','Tamil Nadu','Maharashtra',
                'West Bengal','Gujarat',
                'Rajasthan','Uttar Pradesh')
    END AS state,

    -- signup_date with future dates intentionally
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY)
        ELSE
            DATE_ADD(
                '2021-01-01',
                INTERVAL FLOOR(RAND()*1825) DAY
            )
    END AS signup_date,

    -- loyalty tier with NULLs + mixed casing
    CASE
        WHEN RAND() < 0.04 THEN NULL
        WHEN RAND() < 0.12 THEN
            ELT(FLOOR(1 + RAND()*8),
                'gold','GOLD','silver','SILVER',
                'platinum','PLATINUM','regular','REGULAR')
        ELSE
            ELT(FLOOR(1 + RAND()*4),
                'Regular','Silver','Gold','Platinum')
    END AS loyalty_tier,

    -- invalid customer status labels
    CASE
        WHEN RAND() < 0.05 THEN
            ELT(FLOOR(1 + RAND()*5),
                'active','blocked','inactive',
                'Unknown','Suspended')
        ELSE
            ELT(FLOOR(1 + RAND()*3),
                'Active','Inactive','Blocked')
    END AS customer_status,

    -- annual_spend with NULLs + outliers
    CASE
        WHEN RAND() < 0.03 THEN NULL
        WHEN RAND() < 0.01 THEN ROUND(500000 + RAND()*500000,2)
        WHEN RAND() < 0.01 THEN ROUND(-5000 - RAND()*5000,2)
        ELSE ROUND(5000 + RAND()*195000,2)
    END AS annual_spend

FROM
(
    SELECT
        a.n + b.n*10 + c.n*100 + d.n*1000 + e.n*10000 AS row_num,

        ELT(FLOOR(1 + RAND()*20),
            'Amit','Rahul','Priya','Sneha','Vikram',
            'Anjali','Karan','Neha','Arjun','Pooja',
            'Rohit','Simran','Deepak','Isha','Varun',
            'Meera','Aditya','Nisha','Manoj','Kavya'
        ) AS first_name,

        ELT(FLOOR(1 + RAND()*20),
            'Sharma','Reddy','Patel','Gupta','Iyer',
            'Kapoor','Singh','Verma','Joshi','Nair',
            'Malhotra','Yadav','Mehta','Rao','Pillai',
            'Kulkarni','Chopra','Bose','Mishra','Das'
        ) AS last_name

    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
) names

WHERE row_num < 50000;

-- =========================================================
-- CHECK RECORD COUNT
-- =========================================================

SELECT COUNT(*) AS total_customers
FROM customers;

-- =========================================================
-- SAMPLE DATA
-- =========================================================

SELECT *
FROM customers
LIMIT 20;

-- =========================================================
-- PRODUCTS TABLE + 10,000 SYNTHETIC ROWS
-- Intentional data-quality issues included
-- =========================================================
-- HELPER NUMBERS TABLE (0-9)
-- =========================================================
DROP TABLE IF EXISTS seq_10;
CREATE TABLE seq_10 (n INT NOT NULL);

INSERT INTO seq_10 (n) VALUES
(0),(1),(2),(3),(4),(5),(6),(7),(8),(9);

INSERT INTO products
SELECT
    50001 + row_num AS product_id,
    CASE
        WHEN RAND() < 0.07 THEN CONCAT(pn.product_name, ' ', ELT(1 + MOD(row_num, 5), 'Pro', 'Max', 'Plus', 'X', 'Elite'))
        ELSE pn.product_name
    END AS product_name,
    CASE
        WHEN RAND() < 0.12 THEN
            ELT(FLOOR(1 + RAND()*12),
                'electronics','Electronics','ELECTRONICS',
                'fashion','Fashion','FASHION',
                'grocery','Grocery','GROCERY',
                'home','Home','HOME')
        ELSE
            ELT(FLOOR(1 + RAND()*4),
                'Electronics','Fashion','Grocery','Home')
    END AS category,
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE
            CASE
                WHEN pn.cat_group = 'Electronics' THEN
                    ELT(FLOOR(1 + RAND()*8),
                        'Mobiles','Laptops','Tablets','Headphones',
                        'Smartwatches','Cameras','Accessories','Televisions')
                WHEN pn.cat_group = 'Fashion' THEN
                    ELT(FLOOR(1 + RAND()*8),
                        'Shoes','T-Shirts','Jeans','Watches',
                        'Handbags','Ethnic Wear','Sportswear','Jewellery')
                WHEN pn.cat_group = 'Grocery' THEN
                    ELT(FLOOR(1 + RAND()*8),
                        'Snacks','Beverages','Staples','Personal Care',
                        'Packaged Foods','Dairy','Household','Cooking Essentials')
                ELSE
                    ELT(FLOOR(1 + RAND()*8),
                        'Kitchen','Furniture','Decor','Cleaning',
                        'Storage','Bath','Lighting','Appliances')
            END
    END AS sub_category,
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(FLOOR(1 + RAND()*12),
                'samsung','Samsung','SAMSUNG',
                'nike','Nike','NIKE',
                'boat','Boat','BOAT',
                'apple','Apple','APPLE')
        ELSE
            pn.brand_name
    END AS brand,
    CASE
        WHEN RAND() < 0.01 THEN ROUND(-1 * (500 + RAND()*50000), 2)
        WHEN RAND() < 0.01 THEN ROUND(200000 + RAND()*800000, 2)
        ELSE ROUND(pn.base_price_seed * (0.85 + RAND()*0.7), 2)
    END AS base_price,
    CASE
        WHEN RAND() < 0.02 THEN ROUND(pn.base_price_seed * (1.05 + RAND()*0.35), 2)
        ELSE ROUND(pn.base_price_seed * (0.45 + RAND()*0.40), 2)
    END AS cost_price,
    CASE
        WHEN RAND() < 0.02 THEN ROUND(5.1 + RAND()*2.0, 2)
        WHEN RAND() < 0.01 THEN ROUND(-1 * RAND()*2, 2)
        ELSE ROUND(2.5 + RAND()*2.5, 2)
    END AS product_rating,
    CASE
        WHEN RAND() < 0.05 THEN NULL
        WHEN RAND() < 0.5 THEN 'Yes'
        ELSE 'No'
    END AS return_eligible,
    CASE
        WHEN RAND() < 0.03 THEN 900000 + FLOOR(RAND()*10000)
        ELSE 7001 + FLOOR(RAND()*500)
    END AS seller_id
FROM
(
    SELECT
        a.n + b.n*10 + c.n*100 + d.n*1000 AS row_num,
        CASE
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 4) = 0 THEN 'Electronics'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 4) = 1 THEN 'Fashion'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 4) = 2 THEN 'Grocery'
            ELSE 'Home'
        END AS cat_group,
        CASE
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 6) = 0 THEN 'Samsung'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 6) = 1 THEN 'Nike'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 6) = 2 THEN 'Boat'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 6) = 3 THEN 'Apple'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 6) = 4 THEN 'HP'
            ELSE 'Patanjali'
        END AS brand_name,
        CASE
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 0 THEN 'Noise Smartwatch Pro'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 1 THEN 'Ultra Wireless Headphones'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 2 THEN 'Running Shoes Max'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 3 THEN 'Organic Snack Pack'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 4 THEN '4K Android TV'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 5 THEN 'Fitness Band X'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 6 THEN 'Cotton Casual Shirt'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 7 THEN 'Smartphone Z'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 8 THEN 'Mixer Grinder Plus'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 9 THEN 'Daily Essentials Combo'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 10 THEN 'Gaming Laptop Air'
            ELSE 'Home Decor Lamp'
        END AS product_name,
        CASE
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 0 THEN 24999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 1 THEN 3499
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 2 THEN 5999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 3 THEN 799
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 4 THEN 45999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 5 THEN 1999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 6 THEN 1299
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 7 THEN 15999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 8 THEN 6499
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 9 THEN 999
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 12) = 10 THEN 69999
            ELSE 1899
        END AS base_price_seed
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
) pn
WHERE row_num < 10000;

SELECT COUNT(*) AS total_products FROM products;
SELECT * FROM products LIMIT 20;

-- =========================================================
-- SELLERS TABLE + 2,000 SYNTHETIC ROWS
-- Includes intentional data-quality issues for cleaning practice
-- =========================================================
-- INSERT 2,000 SELLERS
-- =========================================================

INSERT INTO sellers
SELECT
    7001 + row_num AS seller_id,

    -- duplicate seller names intentionally
    CASE
        WHEN RAND() < 0.08 THEN CONCAT(sn.base_name, ' ', ELT(1 + MOD(row_num, 5), 'Pvt Ltd', 'Store', 'Retail', 'Hub', 'Mart'))
        ELSE sn.base_name
    END AS seller_name,

    -- missing city values intentionally
    CASE
        WHEN RAND() < 0.04 THEN NULL
        ELSE
            ELT(FLOOR(1 + RAND()*10),
                'Delhi','Mumbai','Bengaluru','Hyderabad','Chennai',
                'Pune','Kolkata','Ahmedabad','Jaipur','Lucknow')
    END AS seller_city,

    -- ratings with outliers above 5
    CASE
        WHEN RAND() < 0.02 THEN ROUND(5.1 + RAND()*2.5, 2)
        WHEN RAND() < 0.01 THEN ROUND(0.5 + RAND()*0.8, 2)
        ELSE ROUND(2.5 + RAND()*2.4, 2)
    END AS seller_rating,

    -- mixed casing in seller_type
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(FLOOR(1 + RAND()*9),
                'individual','Individual','INDIVIDUAL',
                'business','Business','BUSINESS',
                'brand','Brand','BRAND')
        ELSE
            ELT(FLOOR(1 + RAND()*3),
                'Individual','Business','Brand')
    END AS seller_type,

    -- future onboarding dates intentionally
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY)
        ELSE
            DATE_ADD('2022-01-01', INTERVAL FLOOR(RAND()*1700) DAY)
    END AS onboarding_date,

    -- return rate outliers above 100
    CASE
        WHEN RAND() < 0.02 THEN ROUND(100 + RAND()*75, 2)
        WHEN RAND() < 0.01 THEN ROUND(-1 * RAND()*10, 2)
        ELSE ROUND(RAND()*35, 2)
    END AS return_rate_percent,

    -- invalid seller statuses
    CASE
        WHEN RAND() < 0.05 THEN
            ELT(FLOOR(1 + RAND()*5),
                'active','suspended','inactive','blocked','Unknown')
        ELSE
            ELT(FLOOR(1 + RAND()*3),
                'Active','Suspended','Inactive')
    END AS seller_status

FROM
(
    SELECT
        a.n + b.n*10 + c.n*100 + d.n*1000 AS row_num,
        CASE
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 0 THEN 'Alpha Electronics'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 1 THEN 'Prime Retail'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 2 THEN 'Urban Mart'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 3 THEN 'NextGen Stores'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 4 THEN 'TrendHub'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 5 THEN 'Value Bazaar'
            WHEN MOD(a.n + b.n*10 + c.n*100 + d.n*1000, 8) = 6 THEN 'Fresh Cart'
            ELSE 'Style & Tech'
        END AS base_name
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
) sn
WHERE row_num < 2000;

-- =========================================================
-- CHECKS
-- =========================================================

SELECT COUNT(*) AS total_sellers
FROM sellers;

SELECT *
FROM sellers
LIMIT 20;

-- =========================================================
-- ORDERS TABLE + 250,000 SYNTHETIC ROWS
-- MySQL 8.0+
-- Includes intentional data-quality issues and festival spikes
-- =========================================================
-- INSERT 250,000 ORDERS
-- Festival spikes included:
--   - Diwali period
--   - New Year period
--   - Campaign period
-- =========================================================

INSERT INTO orders
SELECT
    t.order_id,
    t.customer_id,
    t.order_datetime,
    t.order_status,
    t.order_amount,
    t.payment_method,
    t.coupon_used,
    t.delivery_city,
    t.expected_delivery_date,
    t.actual_delivery_date
FROM
(
    SELECT
        9000001 + src.row_num AS order_id,

        CASE
            WHEN RAND() < 0.02 THEN 300000 + FLOOR(RAND() * 50000)
            ELSE 100001 + FLOOR(RAND() * 50000)
        END AS customer_id,

        CASE
            WHEN RAND() < 0.18 THEN
                DATE_ADD(
                    DATE_ADD('2024-10-15 00:00:00', INTERVAL FLOOR(RAND() * 40) DAY),
                    INTERVAL FLOOR(RAND() * 86400) SECOND
                )
            WHEN RAND() < 0.30 THEN
                DATE_ADD(
                    DATE_ADD('2024-12-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY),
                    INTERVAL FLOOR(RAND() * 86400) SECOND
                )
            WHEN RAND() < 0.42 THEN
                DATE_ADD(
                    DATE_ADD('2025-03-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY),
                    INTERVAL FLOOR(RAND() * 86400) SECOND
                )
            ELSE
                DATE_ADD(
                    DATE_ADD('2021-01-01 00:00:00', INTERVAL FLOOR(RAND() * 2190) DAY),
                    INTERVAL FLOOR(RAND() * 86400) SECOND
                )
        END AS order_datetime,

        CASE
            WHEN RAND() < 0.15 THEN
                ELT(FLOOR(1 + RAND() * 9),
                    'delivered','Delivered','DELIVERED',
                    'cancelled','Cancelled','CANCELLED',
                    'returned','Returned','RETURNED')
            ELSE
                ELT(FLOOR(1 + RAND() * 3),
                    'Delivered','Cancelled','Returned')
        END AS order_status,

        CASE
            WHEN RAND() < 0.01 THEN ROUND(-1 * (100 + RAND() * 5000), 2)
            WHEN RAND() < 0.02 THEN ROUND(50000 + RAND() * 500000, 2)
            ELSE ROUND(250 + RAND() * 9750, 2)
        END AS order_amount,

        CASE
            WHEN RAND() < 0.12 THEN
                ELT(FLOOR(1 + RAND() * 10),
                    'upi','UPI','card','Card','cod','COD',
                    'wallet','Wallet','netbanking','Cash')
            ELSE
                ELT(FLOOR(1 + RAND() * 4),
                    'UPI','Card','COD','Wallet')
        END AS payment_method,

        CASE
            WHEN RAND() < 0.05 THEN NULL
            WHEN RAND() < 0.55 THEN 'Yes'
            ELSE 'No'
        END AS coupon_used,

        CASE
            WHEN RAND() < 0.10 THEN
                ELT(FLOOR(1 + RAND() * 10),
                    'mumbai','MUMBAI','delhi','DELHI',
                    'bengaluru','BENGALURU','hyderabad','HYDERABAD',
                    'chennai','CHENNAI')
            ELSE
                ELT(FLOOR(1 + RAND() * 10),
                    'Mumbai','Delhi','Bengaluru','Hyderabad',
                    'Chennai','Pune','Kolkata','Ahmedabad',
                    'Jaipur','Lucknow')
        END AS delivery_city,

        CASE
            WHEN RAND() < 0.03 THEN
                DATE_SUB(DATE(
                    CASE
                        WHEN RAND() < 0.18 THEN DATE_ADD('2024-10-15 00:00:00', INTERVAL FLOOR(RAND() * 40) DAY)
                        WHEN RAND() < 0.30 THEN DATE_ADD('2024-12-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                        WHEN RAND() < 0.42 THEN DATE_ADD('2025-03-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                        ELSE DATE_ADD('2021-01-01 00:00:00', INTERVAL FLOOR(RAND() * 2190) DAY)
                    END
                ), INTERVAL FLOOR(1 + RAND() * 7) DAY)
            ELSE
                DATE_ADD(
                    DATE(
                        CASE
                            WHEN RAND() < 0.18 THEN DATE_ADD('2024-10-15 00:00:00', INTERVAL FLOOR(RAND() * 40) DAY)
                            WHEN RAND() < 0.30 THEN DATE_ADD('2024-12-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                            WHEN RAND() < 0.42 THEN DATE_ADD('2025-03-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                            ELSE DATE_ADD('2021-01-01 00:00:00', INTERVAL FLOOR(RAND() * 2190) DAY)
                        END
                    ),
                    INTERVAL FLOOR(2 + RAND() * 8) DAY
                )
        END AS expected_delivery_date,

        CASE
            WHEN RAND() < 0.02 THEN
                DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY)
            WHEN RAND() < 0.04 THEN
                DATE_SUB(DATE(
                    CASE
                        WHEN RAND() < 0.18 THEN DATE_ADD('2024-10-15 00:00:00', INTERVAL FLOOR(RAND() * 40) DAY)
                        WHEN RAND() < 0.30 THEN DATE_ADD('2024-12-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                        WHEN RAND() < 0.42 THEN DATE_ADD('2025-03-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                        ELSE DATE_ADD('2021-01-01 00:00:00', INTERVAL FLOOR(RAND() * 2190) DAY)
                    END
                ), INTERVAL FLOOR(1 + RAND() * 10) DAY)
            ELSE
                DATE_ADD(
                    DATE(
                        CASE
                            WHEN RAND() < 0.18 THEN DATE_ADD('2024-10-15 00:00:00', INTERVAL FLOOR(RAND() * 40) DAY)
                            WHEN RAND() < 0.30 THEN DATE_ADD('2024-12-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                            WHEN RAND() < 0.42 THEN DATE_ADD('2025-03-20 00:00:00', INTERVAL FLOOR(RAND() * 20) DAY)
                            ELSE DATE_ADD('2021-01-01 00:00:00', INTERVAL FLOOR(RAND() * 2190) DAY)
                        END
                    ),
                    INTERVAL FLOOR(1 + RAND() * 15) DAY
                )
        END AS actual_delivery_date

    FROM
    (
        SELECT
            a.n
            + b.n * 10
            + c.n * 100
            + d.n * 1000
            + e.n * 10000
            + f.n * 100000 AS row_num
        FROM seq_10 a
        CROSS JOIN seq_10 b
        CROSS JOIN seq_10 c
        CROSS JOIN seq_10 d
        CROSS JOIN seq_10 e
        CROSS JOIN seq_10 f
    ) src
    WHERE src.row_num < 250000
) t;
-- =========================================================
-- CHECKS
-- =========================================================

SELECT COUNT(*) AS total_orders
FROM orders;

SELECT *
FROM orders
LIMIT 20;
-- =========================================================
-- ORDER_ITEMS TABLE + 400,000 SYNTHETIC ROWS
-- MySQL 8.0+
-- Based on your requirements
-- =========================================================
-- INSERT 400,000 ORDER ITEMS
-- =========================================================

INSERT INTO order_items
(
    order_item_id,
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    item_total
)
SELECT
    10000001 + src.row_num AS order_item_id,

    -- invalid order references for a small percentage
    CASE
        WHEN RAND() < 0.03 THEN 9500000 + FLOOR(RAND() * 500000)
        ELSE 9000001 + FLOOR(RAND() * 250000)
    END AS order_id,

    -- invalid product references for a small percentage
    CASE
        WHEN RAND() < 0.03 THEN 70000 + FLOOR(RAND() * 20000)
        ELSE 50001 + FLOOR(RAND() * 10000)
    END AS product_id,

    -- zero / negative quantities intentionally
    src.quantity_val AS quantity,

    -- unit_price with outliers and negatives
    src.unit_price_val AS unit_price,

    -- discount greater than price in some cases
    src.discount_val AS discount_amount,

    -- item_total with occasional mismatch
    CASE
        WHEN RAND() < 0.02 THEN ROUND(src.quantity_val * src.unit_price_val - src.discount_val + (RAND() * 500 - 250), 2)
        ELSE ROUND(src.quantity_val * src.unit_price_val - src.discount_val, 2)
    END AS item_total

FROM
(
    SELECT
        t.row_num,

        CASE
            WHEN RAND() < 0.01 THEN 0
            WHEN RAND() < 0.01 THEN -1 * FLOOR(1 + RAND() * 5)
            ELSE FLOOR(1 + RAND() * 6)
        END AS quantity_val,

        CASE
            WHEN RAND() < 0.01 THEN ROUND(50000 + RAND() * 250000, 2)
            WHEN RAND() < 0.01 THEN ROUND(-1 * (100 + RAND() * 5000), 2)
            ELSE ROUND(50 + RAND() * 9950, 2)
        END AS unit_price_val,

        CASE
            WHEN RAND() < 0.02 THEN ROUND(10000 + RAND() * 20000, 2)
            WHEN RAND() < 0.02 THEN ROUND(-1 * RAND() * 500, 2)
            ELSE ROUND(RAND() * 0.35 * (50 + RAND() * 9950), 2)
        END AS discount_val

    FROM
    (
        SELECT
            a.n
            + b.n * 10
            + c.n * 100
            + d.n * 1000
            + e.n * 10000
            + f.n * 100000 AS row_num
        FROM seq_10 a
        CROSS JOIN seq_10 b
        CROSS JOIN seq_10 c
        CROSS JOIN seq_10 d
        CROSS JOIN seq_10 e
        CROSS JOIN seq_10 f
    ) t
    WHERE t.row_num < 400000
) src;

-- =========================================================
-- QUICK CHECKS
-- =========================================================

SELECT COUNT(*) AS total_order_items
FROM order_items;

SELECT *
FROM order_items
LIMIT 20;


-- =========================================================
-- PAYMENTS TABLE + 220,000 SYNTHETIC ROWS
-- orders table already exists
-- Includes intentional data-quality issues for cleaning practice
-- =========================================================

DROP TABLE IF EXISTS tmp_orders;
CREATE TABLE tmp_orders AS
SELECT
    (@rn := @rn + 1) AS rn,
    o.order_id,
    o.order_datetime
FROM
    (SELECT order_id, order_datetime FROM orders ORDER BY order_id) o,
    (SELECT @rn := 0) vars;

-- =========================================================
-- INSERT 220,000 PAYMENTS
-- =========================================================

INSERT INTO payments
SELECT
    -- duplicate payment IDs intentionally
    CASE
        WHEN RAND() < 0.008 THEN 3000001 + MOD(row_num, 5000)
        ELSE 3000001 + row_num
    END AS payment_id,

    -- mostly valid order refs, some invalid
    CASE
        WHEN RAND() < 0.03 THEN 9800000 + FLOOR(RAND() * 300000)
        ELSE mo.order_id
    END AS order_id,

    -- mixed casing / inconsistent payment methods
    CASE
        WHEN RAND() < 0.12 THEN
            ELT(FLOOR(1 + RAND()*12),
                'upi','UPI','Upi',
                'card','Card','CARD',
                'cod','COD','Cod',
                'netbanking','NetBanking','Net Banking')
        ELSE
            ELT(FLOOR(1 + RAND()*4),
                'UPI','Card','COD','NetBanking')
    END AS payment_method,

    -- inconsistent payment statuses
    CASE
        WHEN RAND() < 0.12 THEN
            ELT(FLOOR(1 + RAND()*12),
                'success','Success','SUCCESS',
                'failed','Failed','FAILED',
                'pending','Pending','PENDING',
                'refunded','Refunded','REFUNDED')
        ELSE
            ELT(FLOOR(1 + RAND()*4),
                'Success','Failed','Pending','Refunded')
    END AS payment_status,

    -- negative values intentionally
    CASE
        WHEN RAND() < 0.01 THEN ROUND(-1 * (100 + RAND()*5000), 2)
        WHEN RAND() < 0.015 THEN ROUND(500000 + RAND()*1500000, 2)
        ELSE ROUND(100 + RAND()*14900, 2)
    END AS payment_amount,

    -- payment datetime before order time for some rows
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_SUB(mo.order_datetime, INTERVAL FLOOR(1 + RAND()*120) MINUTE)
        WHEN RAND() < 0.02 THEN
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND()*365) DAY)
        ELSE
            DATE_ADD(mo.order_datetime, INTERVAL FLOOR(0 + RAND()*180) MINUTE)
    END AS payment_datetime,

    -- missing transaction references intentionally
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE CONCAT('TXN_', UPPER(SUBSTRING(MD5(CONCAT(row_num, RAND())), 1, 8)))
    END AS transaction_reference

FROM
(
    SELECT
        a.n
        + b.n*10
        + c.n*100
        + d.n*1000
        + e.n*10000
        + f.n*100000 AS row_num
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
    CROSS JOIN seq_10 f
) t
JOIN tmp_orders mo
    ON mo.rn = (MOD(t.row_num, 250000) + 1)
WHERE t.row_num < 220000;

-- =========================================================
-- QUICK CHECKS
-- =========================================================

SELECT COUNT(*) AS total_payments
FROM payments;
select count(distinct(payment_method)) as mjh
from payments;

SELECT *
FROM payments
LIMIT 20;

/* =========================================================
   RETURNS TABLE + 45,000 SYNTHETIC ROWS
   ---------------------------------------------------------
   Notes:
   1) return_id is INTENTIONALLY NOT a PRIMARY KEY
   2) 0.5% to 1% exact duplicate return_id rows are added
   3) return generation uses:
      - product category
      - product rating
      - delivery delay
      - seller risk
      - customer order history proxy
      - order value
   4) Missing values, mixed casing, invalid timelines, and
      suspicious-return flags are intentionally included
========================================================= */
-- STEP 1: Build an order-level risk profile
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_return_base;

CREATE TEMPORARY TABLE tmp_return_base AS
SELECT
    o.order_id,
    o.customer_id,
    o.order_datetime,
    o.actual_delivery_date,
    o.order_amount,

    /* Normalize category for scoring logic */
    UPPER(COALESCE(p.category, 'UNKNOWN')) AS category_norm,

    COALESCE(p.product_rating, 3.00) AS product_rating,
    COALESCE(s.seller_rating, 3.00) AS seller_rating,
    COALESCE(dl.delay_days, 0) AS delay_days,
    COALESCE(ch.customer_order_count, 1) AS customer_order_count,

    /* -----------------------------------------------------
       Return risk score
       Higher score = higher chance of a return request
       Based on the business rules you requested
    ----------------------------------------------------- */
    (
        /* Category risk */
        CASE
            WHEN UPPER(COALESCE(p.category, '')) IN ('ELECTRONICS', 'FASHION') THEN 2
            WHEN UPPER(COALESCE(p.category, '')) IN ('HOME', 'HOME KITCHEN') THEN 1
            ELSE 0
        END
        +
        /* Low product rating risk */
        CASE
            WHEN COALESCE(p.product_rating, 3.00) < 3.50 THEN 2
            WHEN COALESCE(p.product_rating, 3.00) < 4.00 THEN 1
            ELSE 0
        END
        +
        /* Delivery delay risk */
        CASE
            WHEN COALESCE(dl.delay_days, 0) >= 5 THEN 3
            WHEN COALESCE(dl.delay_days, 0) >= 3 THEN 2
            WHEN COALESCE(dl.delay_days, 0) >= 1 THEN 1
            ELSE 0
        END
        +
        /* Seller risk */
        CASE
            WHEN COALESCE(s.seller_rating, 3.00) < 3.20 THEN 2
            WHEN COALESCE(s.seller_rating, 3.00) < 3.80 THEN 1
            ELSE 0
        END
        +
        /* Return history proxy: repeat buyers/order frequency */
        CASE
            WHEN COALESCE(ch.customer_order_count, 1) >= 10 THEN 2
            WHEN COALESCE(ch.customer_order_count, 1) >= 5 THEN 1
            ELSE 0
        END
        +
        /* Order value risk */
        CASE
            WHEN COALESCE(o.order_amount, 0) >= 50000 THEN 2
            WHEN COALESCE(o.order_amount, 0) >= 15000 THEN 1
            ELSE 0
        END
    ) AS return_risk_score

FROM orders o
LEFT JOIN (
    /* Pick one product per order as the order's representative item */
    SELECT
        order_id,
        MIN(product_id) AS product_id
    FROM order_items
    GROUP BY order_id
) oi
    ON oi.order_id = o.order_id

LEFT JOIN products p
    ON p.product_id = oi.product_id

LEFT JOIN sellers s
    ON s.seller_id = p.seller_id

LEFT JOIN (
    /* Aggregate delivery delay by order */
    SELECT
        order_id,
        MAX(delay_days) AS delay_days
    FROM delivery_logs
    GROUP BY order_id
) dl
    ON dl.order_id = o.order_id

LEFT JOIN (
    /* Customer order count as a proxy for return history */
    SELECT
        customer_id,
        COUNT(*) AS customer_order_count
    FROM orders
    GROUP BY customer_id
) ch
    ON ch.customer_id = o.customer_id

WHERE
    UPPER(COALESCE(o.order_status, '')) IN ('DELIVERED', 'RETURNED')
    OR o.actual_delivery_date IS NOT NULL;

-- =========================================================
-- STEP 2: Turn the risk profile into return-request records
--         This step creates the actual return rows
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_returns_seed;

CREATE TEMPORARY TABLE tmp_returns_seed AS
SELECT
    /* -----------------------------------------------------
       Generate return_id as BIGINT
       Not a primary key, so duplicates are allowed later
    ----------------------------------------------------- */
    8000001 + ROW_NUMBER() OVER (
        ORDER BY
            b.return_risk_score DESC,
            RAND()
    ) - 1 AS return_id,

    b.order_id,
    b.customer_id,

    /* -----------------------------------------------------
       Return reason depends on product/category/risk
    ----------------------------------------------------- */
    CASE
        WHEN b.category_norm = 'FASHION' AND b.order_amount >= 3000 THEN
            ELT(FLOOR(1 + RAND() * 4),
                'Wrong Size',
                'Size issue',
                'Color mismatch',
                'Not as described'
            )

        WHEN b.category_norm = 'ELECTRONICS' AND b.product_rating < 3.50 THEN
            ELT(FLOOR(1 + RAND() * 4),
                'Damaged product',
                'Defective product',
                'Product not working',
                'Missing parts'
            )

        WHEN b.delay_days >= 3 AND b.seller_rating < 3.50 THEN
            ELT(FLOOR(1 + RAND() * 4),
                'Damaged product',
                'Late delivery',
                'Packaging damaged',
                'Wrong item delivered'
            )

        WHEN b.order_amount >= 50000 THEN
            ELT(FLOOR(1 + RAND() * 4),
                'Not as described',
                'Changed mind',
                'Better price elsewhere',
                'Duplicate order'
            )

        WHEN b.customer_order_count >= 5 THEN
            ELT(FLOOR(1 + RAND() * 4),
                'Changed mind',
                'Duplicate order',
                'Wrong item delivered',
                'Quality issue'
            )

        ELSE
            ELT(FLOOR(1 + RAND() * 5),
                'Damaged product',
                'Wrong item delivered',
                'Not as described',
                'Size issue',
                'Changed mind'
            )
    END AS return_reason,

    /* -----------------------------------------------------
       Return request date
       Mostly after delivery, but a small portion is invalid
    ----------------------------------------------------- */
    CASE
        WHEN b.actual_delivery_date IS NOT NULL AND RAND() < 0.08 THEN
            DATE_ADD(
                TIMESTAMP(b.actual_delivery_date, '00:00:00'),
                INTERVAL FLOOR(RAND() * 2) HOUR
            )

        WHEN b.actual_delivery_date IS NOT NULL THEN
            DATE_ADD(
                TIMESTAMP(b.actual_delivery_date, '00:00:00'),
                INTERVAL FLOOR(1 + RAND() * 10) DAY
            )

        ELSE
            DATE_ADD(
                b.order_datetime,
                INTERVAL FLOOR(2 + RAND() * 14) DAY
            )
    END AS return_request_date,

    /* -----------------------------------------------------
       Return decision status with mixed casing
    ----------------------------------------------------- */
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(FLOOR(1 + RAND() * 6),
                'approved',
                'Approved',
                'APPROVED',
                'rejected',
                'Rejected',
                'PENDING'
            )
        ELSE
            ELT(FLOOR(1 + RAND() * 3),
                'Approved',
                'Rejected',
                'Pending'
            )
    END AS return_status,

    /* -----------------------------------------------------
       Pickup status with some missing values
    ----------------------------------------------------- */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        WHEN RAND() < 0.60 THEN 'Picked'
        WHEN RAND() < 0.85 THEN 'Not Picked'
        ELSE 'Failed'
    END AS return_pickup_status,

    /* -----------------------------------------------------
       Suspicious-return flag
       Uses the same risk signals requested in the brief
    ----------------------------------------------------- */
    CASE
        WHEN b.return_risk_score >= 7 THEN b'1'
        WHEN b.return_risk_score >= 5 THEN b'1'
        WHEN b.return_risk_score >= 4 AND RAND() < 0.35 THEN b'1'
        ELSE b'0'
    END AS is_suspicious_return,

    /* -----------------------------------------------------
       Binary flag used for analysis and filtering
       This is the actual return-generation flag
    ----------------------------------------------------- */
    CASE
        WHEN b.return_risk_score >= 7 THEN 1
        WHEN b.return_risk_score >= 5 THEN 1
        WHEN b.return_risk_score >= 4 AND RAND() < 0.35 THEN 1
        WHEN RAND() < 0.04 THEN 1
        ELSE 0
    END AS should_return,

    b.return_risk_score

FROM tmp_return_base b;

-- =========================================================
-- STEP 3: Keep the highest-priority 44,700 unique rows
--         Then add exact duplicate return_id rows
-- =========================================================
INSERT INTO returns (
    return_id,
    order_id,
    customer_id,
    return_reason,
    return_request_date,
    return_status,
    return_pickup_status,
    is_suspicious_return
)
SELECT
    t.return_id,
    t.order_id,
    t.customer_id,
    t.return_reason,
    t.return_request_date,
    t.return_status,
    t.return_pickup_status,
    t.is_suspicious_return
FROM
(
    SELECT
        s.*,
        ROW_NUMBER() OVER (
            ORDER BY
                s.should_return DESC,
                s.return_risk_score DESC,
                RAND()
        ) AS rn
    FROM tmp_returns_seed s
) t
WHERE t.rn <= 44700;

-- =========================================================
-- STEP 4: Insert 300 exact duplicates
--         This creates ~0.67% duplicate rows by return_id
-- =========================================================
INSERT INTO returns (
    return_id,
    order_id,
    customer_id,
    return_reason,
    return_request_date,
    return_status,
    return_pickup_status,
    is_suspicious_return
)
SELECT
    return_id,
    order_id,
    customer_id,
    return_reason,
    return_request_date,
    return_status,
    return_pickup_status,
    is_suspicious_return
FROM returns
ORDER BY RAND()
LIMIT 300;

-- =========================================================
-- QUICK CHECKS
-- =========================================================
SELECT COUNT(*) AS total_returns
FROM returns;

SELECT COUNT(*) AS duplicate_return_id_rows
FROM (
    SELECT return_id, COUNT(*) AS c
    FROM returns
    GROUP BY return_id
    HAVING COUNT(*) > 1
) x;

SELECT *
FROM returns
LIMIT 20;

/* =========================================================
   REFUNDS TABLE + 35,000 SYNTHETIC ROWS
   ---------------------------------------------------------
   Business goals:
   - Refund approval / processing analysis
   - Refund mismatch testing
   - Missing values and invalid references
   - Mixed casing and invalid dates
   - Refund amount greater than order value in selected cases
========================================================= */
-- STEP 1: Rank RETURNS so we can pick rows quickly
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_returns_rank;
CREATE TEMPORARY TABLE tmp_returns_rank AS
SELECT
    r.return_id,
    r.order_id,
    r.customer_id,
    r.return_request_date,
    r.return_status,
    r.return_pickup_status,
    r.is_suspicious_return,
    ROW_NUMBER() OVER (ORDER BY r.return_id) AS rn
FROM returns r;

DROP TEMPORARY TABLE IF EXISTS tmp_return_count;
CREATE TEMPORARY TABLE tmp_return_count AS
SELECT COUNT(*) AS cnt
FROM tmp_returns_rank;

-- =========================================================
-- STEP 2: Generate 35,000 refund records
-- =========================================================
INSERT INTO refunds (
    refund_id,
    return_id,
    refund_amount,
    refund_status,
    refund_method,
    refund_processed_date,
    refund_reason_code
)
SELECT
    8500001 + seq.rn AS refund_id,

    /* invalid return_id for a small percentage */
    CASE
        WHEN RAND() < 0.02 THEN 9000000 + FLOOR(RAND() * 50000)
        ELSE rr.return_id
    END AS return_id,

    /* refund amount:
       - normal refunds based on order amount
       - some refunds greater than order amount
       - some negative values
    */
    CASE
        WHEN RAND() < 0.015 THEN
            ROUND(COALESCE(o.order_amount, 1000) * (1.10 + RAND() * 0.60), 2)
        WHEN RAND() < 0.010 THEN
            ROUND(-1 * (100 + RAND() * 5000), 2)
        ELSE
            ROUND(COALESCE(o.order_amount, 1000) * (0.50 + RAND() * 0.50), 2)
    END AS refund_amount,

    /* mixed casing / invalid refund statuses */
    CASE
        WHEN RAND() < 0.12 THEN
            ELT(FLOOR(1 + RAND() * 6),
                'processed',
                'Processed',
                'PROCESSED',
                'pending',
                'Pending',
                'REJECTED'
            )
        ELSE
            ELT(FLOOR(1 + RAND() * 3),
                'Processed',
                'Pending',
                'Rejected'
            )
    END AS refund_status,

    /* invalid refund methods */
    CASE
        WHEN RAND() < 0.10 THEN
            ELT(FLOOR(1 + RAND() * 8),
                'original payment',
                'Original Payment',
                'wallet',
                'Wallet',
                'coupon',
                'Coupon',
                'bank transfer',
                'Crypto'
            )
        ELSE
            ELT(FLOOR(1 + RAND() * 3),
                'Original Payment',
                'Wallet',
                'Coupon'
            )
    END AS refund_method,

    /* refund date:
       - sometimes before return request date
       - sometimes future date
       - normally after return request date
    */
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_SUB(DATE(rr.return_request_date), INTERVAL FLOOR(1 + RAND() * 5) DAY)
        WHEN RAND() < 0.02 THEN
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY)
        ELSE
            DATE_ADD(DATE(rr.return_request_date), INTERVAL FLOOR(1 + RAND() * 14) DAY)
    END AS refund_processed_date,

    /* missing reason codes */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE
            ELT(FLOOR(1 + RAND() * 7),
                'DAMAGED_PRODUCT',
                'WRONG_ITEM',
                'NOT_AS_DESCRIBED',
                'SIZE_ISSUE',
                'QUALITY_ISSUE',
                'DEFECTIVE_PRODUCT',
                'CUSTOMER_CANCELLED'
            )
    END AS refund_reason_code

FROM
(
    /* generate 35,000 sequence rows */
    SELECT
        a.n
        + b.n * 10
        + c.n * 100
        + d.n * 1000
        + e.n * 10000 AS rn
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
) seq
JOIN tmp_return_count rc
JOIN tmp_returns_rank rr
    ON rr.rn = (seq.rn MOD rc.cnt) + 1
LEFT JOIN orders o
    ON o.order_id = rr.order_id
WHERE seq.rn < 35000;

-- =========================================================
-- VALIDATION
-- =========================================================
SELECT COUNT(*) AS total_refunds
FROM refunds;

SELECT COUNT(*) AS invalid_return_refs
FROM refunds rf
LEFT JOIN returns r
    ON r.return_id = rf.return_id
WHERE r.return_id IS NULL;
-- =========================================================
-- OPTIONAL QUALITY CHECKS
-- =========================================================
SELECT *
FROM refunds
LIMIT 20;
  
/* =========================================================
   DELIVERY_LOGS TABLE + 180,000 ROWS
   ---------------------------------------------------------
   Requirements covered:
   - duplicate logs
   - invalid order IDs
   - missing warehouse IDs
   - inconsistent delivery partner names
   - dispatch dates before order dates
   - delivery attempt outliers
   - mixed-case delivery status
   - negative delay_days
   - 0.5% to 1% duplicate rows
========================================================= */
-- STEP 1: Rank ORDERS and WAREHOUSES for fast set-based joins
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_orders_rank;
CREATE TEMPORARY TABLE tmp_orders_rank AS
SELECT
    o.order_id,
    o.order_datetime,
    ROW_NUMBER() OVER (ORDER BY o.order_id) AS rn
FROM orders o;

DROP TEMPORARY TABLE IF EXISTS tmp_warehouses_rank;
CREATE TEMPORARY TABLE tmp_warehouses_rank AS
SELECT
    w.warehouse_id,
    ROW_NUMBER() OVER (ORDER BY w.warehouse_id) AS rn
FROM warehouses w;

DROP TEMPORARY TABLE IF EXISTS tmp_order_count;
CREATE TEMPORARY TABLE tmp_order_count AS
SELECT COUNT(*) AS cnt
FROM tmp_orders_rank;

DROP TEMPORARY TABLE IF EXISTS tmp_wh_count;
CREATE TEMPORARY TABLE tmp_wh_count AS
SELECT COUNT(*) AS cnt
FROM tmp_warehouses_rank;

-- =========================================================
-- STEP 2: Build a base delivery log dataset
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_delivery_base;

CREATE TEMPORARY TABLE tmp_delivery_base AS
SELECT
    6000001 + seq.rn AS delivery_id,
    o.order_id,
    o.order_datetime,

    /* Missing warehouse IDs + invalid warehouse IDs */
    CASE
        WHEN RAND() < 0.04 THEN NULL
        WHEN RAND() < 0.02 THEN 900 + FLOOR(RAND() * 1000)
        ELSE w.warehouse_id
    END AS warehouse_id,

    /* Inconsistent delivery partner names */
    CASE
        WHEN RAND() < 0.20 THEN
            ELT(
                FLOOR(1 + RAND() * 12),
                'Delhivery',
                'delhivery',
                'DELHIVERY',
                'Ekart',
                'EKART',
                'BlueDart',
                'Blue Dart',
                'xpressbees',
                'XpressBees',
                'Shadowfax',
                'shadowfax',
                'India Post'
            )
        ELSE
            ELT(
                FLOOR(1 + RAND() * 6),
                'Delhivery',
                'Ekart',
                'BlueDart',
                'XpressBees',
                'Shadowfax',
                'India Post'
            )
    END AS delivery_partner,

    /* Partner/warehouse risk flags for delay logic */
    CASE
        WHEN RAND() < 0.20 THEN 1
        WHEN UPPER(REPLACE(
            ELT(
                FLOOR(1 + RAND() * 6),
                'Delhivery',
                'Ekart',
                'BlueDart',
                'XpressBees',
                'Shadowfax',
                'India Post'
            ), ' ', ''
        )) IN ('DELHIVERY', 'EKART', 'XPRESSBEES', 'SHADOWFAX')
        THEN 1
        ELSE 0
    END AS partner_risk_flag,

    CASE
        WHEN w.warehouse_id IN (101, 104, 112, 127, 139) THEN 1
        ELSE 0
    END AS warehouse_risk_flag

FROM
(
    SELECT
        a.n
        + b.n * 10
        + c.n * 100
        + d.n * 1000
        + e.n * 10000
        + f.n * 100000 AS rn
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
    CROSS JOIN seq_10 f
) seq
JOIN tmp_order_count oc
JOIN tmp_orders_rank o
    ON o.rn = (seq.rn MOD oc.cnt) + 1
JOIN tmp_wh_count wc
JOIN tmp_warehouses_rank w
    ON w.rn = ((seq.rn * 3) MOD wc.cnt) + 1
WHERE seq.rn < 180000;

-- =========================================================
-- STEP 3: Insert 180,000 delivery logs
-- =========================================================
INSERT INTO delivery_logs
SELECT
    b.delivery_id,

    /* Invalid order IDs for a small percentage */
    CASE
        WHEN RAND() < 0.005 THEN 990000000 + FLOOR(RAND() * 100000)
        ELSE b.order_id
    END AS order_id,

    b.warehouse_id,
    b.delivery_partner,

    /* Dispatch date:
       - some before order date
       - risk-based delays for certain partners/warehouses
    */
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_SUB(DATE(b.order_datetime), INTERVAL FLOOR(1 + RAND() * 4) DAY)

        WHEN b.partner_risk_flag = 1 OR b.warehouse_risk_flag = 1 THEN
            DATE_ADD(DATE(b.order_datetime), INTERVAL FLOOR(2 + RAND() * 5) DAY)

        ELSE
            DATE_ADD(DATE(b.order_datetime), INTERVAL FLOOR(RAND() * 2) DAY)
    END AS dispatch_date,

    /* Delivery attempts:
       - outliers like 15
       - higher attempts for risky partners/warehouses
    */
    CASE
        WHEN (b.partner_risk_flag = 1 OR b.warehouse_risk_flag = 1) AND RAND() < 0.08 THEN 15
        WHEN b.partner_risk_flag = 1 OR b.warehouse_risk_flag = 1 THEN FLOOR(3 + RAND() * 4)
        WHEN RAND() < 0.01 THEN 15
        ELSE FLOOR(1 + RAND() * 3)
    END AS delivery_attempts,

    /* Delivery status with mixed casing */
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(
                FLOOR(1 + RAND() * 7),
                'delivered',
                'Delivered',
                'DELIVERED',
                'failed',
                'Failed',
                'returned',
                'Returned'
            )
        ELSE
            ELT(
                FLOOR(1 + RAND() * 3),
                'Delivered',
                'Failed',
                'Returned'
            )
    END AS delivery_status,

    /* Delay days:
       - higher delay for risky partners / warehouses
       - some negative values intentionally
    */
    CASE
        WHEN b.partner_risk_flag = 1 OR b.warehouse_risk_flag = 1 THEN
            CASE
                WHEN RAND() < 0.05 THEN -FLOOR(1 + RAND() * 3)
                ELSE FLOOR(2 + RAND() * 10)
            END

        ELSE
            CASE
                WHEN RAND() < 0.01 THEN -FLOOR(1 + RAND() * 4)
                WHEN RAND() < 0.10 THEN FLOOR(4 + RAND() * 6)
                ELSE FLOOR(RAND() * 4)
            END
    END AS delay_days

FROM tmp_delivery_base b;

-- =========================================================
-- STEP 4: Add duplicate delivery log rows
-- 0.5% to 1% duplicate records
-- =========================================================
INSERT INTO delivery_logs
SELECT *
FROM delivery_logs
ORDER BY RAND()
LIMIT 1200;

-- =========================================================
-- VALIDATION
-- =========================================================
SELECT COUNT(*) AS total_delivery_logs
FROM delivery_logs;

SELECT COUNT(*) AS duplicate_delivery_ids
FROM (
    SELECT delivery_id, COUNT(*) AS c
    FROM delivery_logs
    GROUP BY delivery_id
    HAVING COUNT(*) > 1
) x;

SELECT COUNT(*) AS invalid_order_refs
FROM delivery_logs d
LEFT JOIN orders o
    ON o.order_id = d.order_id
WHERE o.order_id IS NULL;

SELECT *
FROM delivery_logs
LIMIT 20;

/* =========================================================
   WAREHOUSES TABLE + 50 SYNTHETIC ROWS
   ---------------------------------------------------------
   Quality issues included:
   - extra spaces / casing issues in warehouse_name
   - spelling inconsistencies in city
   - missing state values
   - invalid regions
   - outlier capacity_units
   - negative avg_dispatch_time_hours
========================================================= */
-- INSERT 50 WAREHOUSES
-- =========================================================
INSERT INTO warehouses
SELECT
    101 + row_num AS warehouse_id,

    /* extra spaces + casing issues */
    CASE
        WHEN RAND() < 0.20 THEN CONCAT('  ', base.wh_name, '  ')
        WHEN RAND() < 0.20 THEN UPPER(base.wh_name)
        WHEN RAND() < 0.20 THEN LOWER(base.wh_name)
        ELSE base.wh_name
    END AS warehouse_name,

    /* city spelling / casing inconsistencies */
    CASE
        WHEN RAND() < 0.15 THEN
            ELT(FLOOR(1 + RAND() * 10),
                'hyderabad','HYDERABAD',
                'bengaluru','BENGALURU',
                'mumbai','MUMBAI',
                'delhi','DELHI',
                'chennai','CHENNAI')
        ELSE base.city
    END AS city,

    /* missing state values */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE base.state
    END AS state,

    /* invalid regions */
    CASE
        WHEN RAND() < 0.10 THEN
            ELT(FLOOR(1 + RAND() * 6),
                'NorthEast','Central','WestSide','SouthZone','Unknown','OutsideIndia')
        ELSE base.region
    END AS region,

    /* outliers in capacity_units */
    CASE
        WHEN RAND() < 0.03 THEN FLOOR(1000000 + RAND() * 9000000)
        ELSE base.capacity_units
    END AS capacity_units,

    /* negative avg_dispatch_time_hours */
    CASE
        WHEN RAND() < 0.03 THEN ROUND(-1 * (1 + RAND() * 20), 2)
        ELSE ROUND(base.avg_dispatch_time_hours + (RAND() * 4 - 2), 2)
    END AS avg_dispatch_time_hours

FROM
(
    SELECT
        a.n + b.n * 10 AS row_num,
        CASE
            WHEN MOD(a.n + b.n * 10, 10) = 0 THEN 'HYD Central Warehouse'
            WHEN MOD(a.n + b.n * 10, 10) = 1 THEN 'BLR South Hub'
            WHEN MOD(a.n + b.n * 10, 10) = 2 THEN 'MUM West Depot'
            WHEN MOD(a.n + b.n * 10, 10) = 3 THEN 'DEL North Fulfillment'
            WHEN MOD(a.n + b.n * 10, 10) = 4 THEN 'CHEN East Center'
            WHEN MOD(a.n + b.n * 10, 10) = 5 THEN 'PUNE Regional Hub'
            WHEN MOD(a.n + b.n * 10, 10) = 6 THEN 'KOL Warehouse'
            WHEN MOD(a.n + b.n * 10, 10) = 7 THEN 'AHM Central Store'
            WHEN MOD(a.n + b.n * 10, 10) = 8 THEN 'LKO Dispatch Center'
            ELSE 'JAI Logistics Point'
        END AS wh_name,

        CASE
            WHEN MOD(a.n + b.n * 10, 10) = 0 THEN 'Hyderabad'
            WHEN MOD(a.n + b.n * 10, 10) = 1 THEN 'Bengaluru'
            WHEN MOD(a.n + b.n * 10, 10) = 2 THEN 'Mumbai'
            WHEN MOD(a.n + b.n * 10, 10) = 3 THEN 'Delhi'
            WHEN MOD(a.n + b.n * 10, 10) = 4 THEN 'Chennai'
            WHEN MOD(a.n + b.n * 10, 10) = 5 THEN 'Pune'
            WHEN MOD(a.n + b.n * 10, 10) = 6 THEN 'Kolkata'
            WHEN MOD(a.n + b.n * 10, 10) = 7 THEN 'Ahmedabad'
            WHEN MOD(a.n + b.n * 10, 10) = 8 THEN 'Lucknow'
            ELSE 'Jaipur'
        END AS city,

        CASE
            WHEN MOD(a.n + b.n * 10, 10) = 0 THEN 'Telangana'
            WHEN MOD(a.n + b.n * 10, 10) = 1 THEN 'Karnataka'
            WHEN MOD(a.n + b.n * 10, 10) = 2 THEN 'Maharashtra'
            WHEN MOD(a.n + b.n * 10, 10) = 3 THEN 'Delhi'
            WHEN MOD(a.n + b.n * 10, 10) = 4 THEN 'Tamil Nadu'
            WHEN MOD(a.n + b.n * 10, 10) = 5 THEN 'Maharashtra'
            WHEN MOD(a.n + b.n * 10, 10) = 6 THEN 'West Bengal'
            WHEN MOD(a.n + b.n * 10, 10) = 7 THEN 'Gujarat'
            WHEN MOD(a.n + b.n * 10, 10) = 8 THEN 'Uttar Pradesh'
            ELSE 'Rajasthan'
        END AS state,

        CASE
            WHEN MOD(a.n + b.n * 10, 4) = 0 THEN 'South'
            WHEN MOD(a.n + b.n * 10, 4) = 1 THEN 'West'
            WHEN MOD(a.n + b.n * 10, 4) = 2 THEN 'North'
            ELSE 'East'
        END AS region,

        CASE
            WHEN MOD(a.n + b.n * 10, 10) = 0 THEN 500000
            WHEN MOD(a.n + b.n * 10, 10) = 1 THEN 420000
            WHEN MOD(a.n + b.n * 10, 10) = 2 THEN 380000
            WHEN MOD(a.n + b.n * 10, 10) = 3 THEN 600000
            WHEN MOD(a.n + b.n * 10, 10) = 4 THEN 450000
            WHEN MOD(a.n + b.n * 10, 10) = 5 THEN 350000
            WHEN MOD(a.n + b.n * 10, 10) = 6 THEN 300000
            WHEN MOD(a.n + b.n * 10, 10) = 7 THEN 280000
            WHEN MOD(a.n + b.n * 10, 10) = 8 THEN 260000
            ELSE 240000
        END AS capacity_units,

        CASE
            WHEN MOD(a.n + b.n * 10, 10) = 0 THEN 18.50
            WHEN MOD(a.n + b.n * 10, 10) = 1 THEN 20.25
            WHEN MOD(a.n + b.n * 10, 10) = 2 THEN 17.00
            WHEN MOD(a.n + b.n * 10, 10) = 3 THEN 22.10
            WHEN MOD(a.n + b.n * 10, 10) = 4 THEN 19.75
            WHEN MOD(a.n + b.n * 10, 10) = 5 THEN 16.80
            WHEN MOD(a.n + b.n * 10, 10) = 6 THEN 21.40
            WHEN MOD(a.n + b.n * 10, 10) = 7 THEN 23.60
            WHEN MOD(a.n + b.n * 10, 10) = 8 THEN 15.90
            ELSE 24.30
        END AS avg_dispatch_time_hours

    FROM seq_10 a
    CROSS JOIN seq_10 b
) base
WHERE row_num < 50;

-- =========================================================
-- CHECKS
-- =========================================================
SELECT COUNT(*) AS total_warehouses
FROM warehouses;

SELECT *
FROM warehouses
LIMIT 20;

/* =========================================================
   REVIEWS TABLE + 100,000 SYNTHETIC ROWS
   ---------------------------------------------------------
   Quality issues included:
   - duplicate reviews
   - invalid order IDs
   - missing customer IDs
   - invalid product IDs
   - rating outliers like 0 and 8
   - NULL review_text
   - review_date before delivery date
========================================================= */
-- BASE DATA: one product per order + delivery date context
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_review_base;

CREATE TEMPORARY TABLE tmp_review_base AS
SELECT
    o.order_id,
    o.customer_id,
    o.actual_delivery_date,
    o.order_datetime,
    oi.product_id,
    p.product_rating,
    p.category,
    p.brand,
    ROW_NUMBER() OVER (ORDER BY o.order_id) AS rn
FROM orders o
LEFT JOIN (
    SELECT order_id, MIN(product_id) AS product_id
    FROM order_items
    GROUP BY order_id
) oi
    ON oi.order_id = o.order_id
LEFT JOIN products p
    ON p.product_id = oi.product_id
WHERE o.order_id IS NOT NULL;

DROP TEMPORARY TABLE IF EXISTS tmp_review_count;

CREATE TEMPORARY TABLE tmp_review_count AS
SELECT COUNT(*) AS cnt
FROM tmp_review_base;

-- =========================================================
-- INSERT 100,000 REVIEWS
-- =========================================================
INSERT INTO reviews (
    review_id,
    order_id,
    customer_id,
    product_id,
    rating,
    review_text,
    review_date
)
SELECT
    9500001 + seq.rn AS review_id,

    /* invalid order IDs for a small percentage */
    CASE
        WHEN RAND() < 0.005 THEN 990000000 + FLOOR(RAND() * 100000)
        ELSE rb.order_id
    END AS order_id,

    /* missing customer IDs for a small percentage */
    CASE
        WHEN RAND() < 0.04 THEN NULL
        ELSE rb.customer_id
    END AS customer_id,

    /* invalid product IDs for a small percentage */
    CASE
        WHEN RAND() < 0.01 THEN 800000 + FLOOR(RAND() * 100000)
        ELSE COALESCE(rb.product_id, 50001 + FLOOR(RAND() * 10000))
    END AS product_id,

    /* ratings with outliers like 0 and 8 */
    CASE
        WHEN RAND() < 0.01 THEN 0
        WHEN RAND() < 0.01 THEN 8
        ELSE
            CASE
                WHEN COALESCE(rb.product_rating, 3.8) >= 4.5 THEN
                    ELT(FLOOR(1 + RAND() * 2), 4, 5)
                WHEN COALESCE(rb.product_rating, 3.8) >= 3.5 THEN
                    ELT(FLOOR(1 + RAND() * 3), 3, 4, 5)
                ELSE
                    ELT(FLOOR(1 + RAND() * 4), 1, 2, 3, 4)
            END
    END AS rating,

    /* review text with NULLs intentionally added */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE
            CASE
                WHEN COALESCE(rb.product_rating, 3.8) < 3.0 THEN
                    ELT(FLOOR(1 + RAND() * 5),
                        'Product damaged and late delivery.',
                        'Very poor quality, not satisfied.',
                        'Item not as described.',
                        'Delivery was late and packaging was damaged.',
                        'Would not recommend this product.')
                WHEN COALESCE(rb.product_rating, 3.8) >= 4.5 THEN
                    ELT(FLOOR(1 + RAND() * 5),
                        'Great product! Exactly as described.',
                        'Excellent quality, will buy again.',
                        'Delivered on time, very happy with purchase.',
                        'Good value for money.',
                        'Very satisfied with the product.')
                ELSE
                    ELT(FLOOR(1 + RAND() * 5),
                        'Average product, okay for the price.',
                        'Delivery took longer than expected.',
                        'Product quality is decent.',
                        'Satisfactory overall experience.',
                        'Not bad, but could be better.')
            END
    END AS review_text,

    /* review_date:
       - usually after delivery
       - some intentionally before delivery
    */
    CASE
        WHEN rb.actual_delivery_date IS NOT NULL AND RAND() < 0.03 THEN
            DATE_SUB(rb.actual_delivery_date, INTERVAL FLOOR(1 + RAND() * 5) DAY)
        WHEN rb.actual_delivery_date IS NOT NULL THEN
            DATE_ADD(rb.actual_delivery_date, INTERVAL FLOOR(1 + RAND() * 20) DAY)
        ELSE
            DATE_ADD(DATE(rb.order_datetime), INTERVAL FLOOR(1 + RAND() * 20) DAY)
    END AS review_date

FROM
(
    SELECT
        a.n
        + b.n * 10
        + c.n * 100
        + d.n * 1000
        + e.n * 10000 AS rn
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
) seq
JOIN tmp_review_count rc
JOIN tmp_review_base rb
    ON rb.rn = (seq.rn MOD rc.cnt) + 1
WHERE seq.rn < 100000;

-- =========================================================
-- DUPLICATE REVIEW ROWS
-- 0.5% to 1% duplicate records
-- =========================================================
INSERT INTO reviews
SELECT *
FROM reviews
ORDER BY RAND()
LIMIT 700;

-- =========================================================
-- VALIDATION
-- =========================================================
SELECT COUNT(*) AS total_reviews
FROM reviews;

SELECT COUNT(*) AS duplicate_review_id_rows
FROM (
    SELECT review_id, COUNT(*) AS c
    FROM reviews
    GROUP BY review_id
    HAVING COUNT(*) > 1
) x;

SELECT COUNT(*) AS invalid_order_refs
FROM reviews rv
LEFT JOIN orders o
    ON o.order_id = rv.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS invalid_product_refs
FROM reviews rv
LEFT JOIN products p
    ON p.product_id = rv.product_id
WHERE p.product_id IS NULL;

SELECT *
FROM reviews
LIMIT 20;

/* =========================================================
   CUSTOMER_SUPPORT_TICKETS TABLE + 60,000 ROWS
   ---------------------------------------------------------
   Requirements covered:
   - ticket_id unique, no duplicates
   - invalid customer IDs
   - NULL order_id allowed
   - missing ticket categories
   - future timestamps
   - mixed casing in resolution status
   - negative and extreme resolution times
   - NULL customer sentiment
========================================================= */
-- RANK CUSTOMERS AND ORDERS FOR FAST SET-BASED SAMPLING
-- =========================================================
DROP TEMPORARY TABLE IF EXISTS tmp_customers_rank;
CREATE TEMPORARY TABLE tmp_customers_rank AS
SELECT
    c.customer_id,
    ROW_NUMBER() OVER (ORDER BY c.customer_id) AS rn
FROM customers c;

DROP TEMPORARY TABLE IF EXISTS tmp_orders_rank;
CREATE TEMPORARY TABLE tmp_orders_rank AS
SELECT
    o.order_id,
    o.order_datetime,
    ROW_NUMBER() OVER (ORDER BY o.order_id) AS rn
FROM orders o;

DROP TEMPORARY TABLE IF EXISTS tmp_customer_count;

CREATE TEMPORARY TABLE tmp_customer_count AS
SELECT COUNT(*) AS cnt
FROM tmp_customers_rank;

DROP TEMPORARY TABLE IF EXISTS tmp_order_count;
CREATE TEMPORARY TABLE tmp_order_count AS
SELECT COUNT(*) AS cnt
FROM tmp_orders_rank;

-- =========================================================
-- INSERT 60,000 SUPPORT TICKETS
-- =========================================================
INSERT INTO customer_support_tickets (
    ticket_id,
    customer_id,
    order_id,
    ticket_category,
    ticket_created_date,
    resolution_status,
    resolution_time_hours,
    customer_sentiment
)
SELECT
    7500001 + seq.rn AS ticket_id,

    /* Invalid customer IDs for a small percentage */
    CASE
        WHEN RAND() < 0.02 THEN 300000 + FLOOR(RAND() * 50000)
        ELSE c.customer_id
    END AS customer_id,

    /* NULL order_id allowed */
    CASE
        WHEN RAND() < 0.12 THEN NULL
        WHEN RAND() < 0.02 THEN 990000000 + FLOOR(RAND() * 50000)
        ELSE o.order_id
    END AS order_id,

    /* Missing categories intentionally included */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE
            ELT(
                FLOOR(1 + RAND() * 9),
                'Refund',
                'Delivery',
                'Product Quality',
                'Cancellation',
                'Payment Issue',
                'Wrong Item',
                'Return Request',
                'Technical Support',
                'Account Issue'
            )
    END AS ticket_category,

    /* Ticket created date:
       - mostly after the order
       - some future timestamps intentionally
    */
    CASE
        WHEN RAND() < 0.03 THEN
            DATE_ADD(CURDATE(), INTERVAL FLOOR(RAND() * 365) DAY)

        WHEN o.order_datetime IS NOT NULL THEN
            DATE_ADD(
                o.order_datetime,
                INTERVAL FLOOR(RAND() * 20) DAY
            )

        ELSE
            DATE_ADD(
                '2021-01-01 00:00:00',
                INTERVAL FLOOR(RAND() * 1500) DAY
            )
    END AS ticket_created_date,

    /* Mixed casing / invalid resolution statuses */
    CASE
        WHEN RAND() < 0.18 THEN
            ELT(
                FLOOR(1 + RAND() * 6),
                'open',
                'Open',
                'OPEN',
                'resolved',
                'Resolved',
                'ESCALATED'
            )
        ELSE
            ELT(
                FLOOR(1 + RAND() * 3),
                'Open',
                'Resolved',
                'Escalated'
            )
    END AS resolution_status,

    /* Negative and extreme resolution times */
    CASE
        WHEN RAND() < 0.02 THEN -FLOOR(1 + RAND() * 24)
        WHEN RAND() < 0.02 THEN FLOOR(500 + RAND() * 1000)
        ELSE FLOOR(1 + RAND() * 72)
    END AS resolution_time_hours,

    /* NULL customer sentiment intentionally added */
    CASE
        WHEN RAND() < 0.05 THEN NULL
        ELSE
            ELT(
                FLOOR(1 + RAND() * 3),
                'Positive',
                'Neutral',
                'Negative'
            )
    END AS customer_sentiment

FROM
(
    SELECT
        a.n
        + b.n * 10
        + c.n * 100
        + d.n * 1000
        + e.n * 10000 AS rn
    FROM seq_10 a
    CROSS JOIN seq_10 b
    CROSS JOIN seq_10 c
    CROSS JOIN seq_10 d
    CROSS JOIN seq_10 e
) seq
JOIN tmp_customer_count cc
JOIN tmp_customers_rank c
    ON c.rn = (seq.rn MOD cc.cnt) + 1
JOIN tmp_order_count oc
JOIN tmp_orders_rank o
    ON o.rn = ((seq.rn * 7) MOD oc.cnt) + 1
WHERE seq.rn < 60000;
  

-- =========================================================
-- VALIDATION
-- =========================================================
SELECT COUNT(*) AS total_tickets
FROM customer_support_tickets;

SELECT COUNT(*) AS invalid_customer_refs
FROM customer_support_tickets t
LEFT JOIN customers c
    ON c.customer_id = t.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) AS null_order_ids
FROM customer_support_tickets
WHERE order_id IS NULL;

SELECT COUNT(*) AS future_tickets
FROM customer_support_tickets
WHERE ticket_created_date > NOW();

SELECT *
FROM customer_support_tickets
LIMIT 20;

-- =======================================
--  Checking invalid references
-- =====================================

use ecommerce_db;
-- Orders
-- check invalid customers
SELECT
    o.order_id,
    o.customer_id
FROM orders o
LEFT JOIN customers c
    ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT
   count(*) as invalid_customers
FROM orders o
LEFT JOIN customers c
    ON c.customer_id = o.customer_id
WHERE c.customer_id IS NULL;

-- Order_items
-- check invalid references
SELECT
    oi.order_id,
    o.order_id
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
   count(*) as invalid_orders
FROM order_items oi
LEFT JOIN orders o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;
-- invalid products
SELECT
    oi.product_id,
    p.product_id
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
    count(*) as invalid_products
FROM order_items oi
LEFT JOIN products p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Products 
-- check invalid sellers in products table
SELECT
    p.seller_id,
    s.seller_id
FROM products p
LEFT JOIN sellers s
    ON p.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

SELECT
    count(*) as invalid_sellers
FROM products p
LEFT JOIN sellers s
    ON p.seller_id = s.seller_id
WHERE s.seller_id IS NULL;

-- payments table
-- check invalid orders
SELECT
    p.order_id,
    o.order_id
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
   count(*) as invalid_orders
FROM payments p
LEFT JOIN orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- returns table
-- check invalid orders
SELECT
    r.order_id,
    r.order_id
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT COUNT(*) AS invalid_order_refs
FROM returns r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- refunds table
-- check invalid returns
SELECT
    rf.return_id,
    r.return_id
FROM refunds rf
LEFT JOIN returns r
    ON rf.return_id = r.return_id
WHERE r.return_id IS NULL;

SELECT
    count(*) as invalid_returns
FROM refunds rf
LEFT JOIN returns r
    ON rf.return_id = r.return_id
WHERE r.return_id IS NULL;

-- delivery_logs table
-- check invalid orders 
SELECT
    d.order_id,
    o.order_id
FROM  delivery_logs d
LEFT JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
    count(*) as invalid_orders
FROM  delivery_logs d
LEFT JOIN orders o
    ON d.order_id = o.order_id
WHERE o.order_id IS NULL;

-- reviews table 
-- check inavlid orders
SELECT
    r.order_id,
    o.order_id
FROM  reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

SELECT
    count(*) as invalid_orders
FROM  reviews r
LEFT JOIN orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- check invalid products
SELECT
    r.product_id,
    p.product_id
FROM  reviews r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;

SELECT
    count(*) as inavlid_products
FROM  reviews r
LEFT JOIN products p
    ON r.product_id = p.product_id
WHERE p.product_id IS NULL;

/* SELECT
    r.customer_id,
    c.customer_id
FROM  reviews r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT
   count(*) as invalid_customers
FROM  reviews r
LEFT JOIN customers c
    ON r.customer_id = c.customer_id
WHERE c.customer_id IS NULL; */

-- customer_support_tickets table
-- check invalid customers
SELECT
    cst.customer_id,
    c.customer_id
FROM  customer_support_tickets cst
LEFT JOIN customers c
    ON cst.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT
    count(*) as invalid_customers
FROM  customer_support_tickets cst
LEFT JOIN customers c
    ON cst.customer_id = c.customer_id
WHERE c.customer_id IS NULL;