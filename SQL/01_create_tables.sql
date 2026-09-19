-- ============================================================
-- FinTech Transaction Analytics
-- File: 01_create_tables.sql
-- Purpose: Create core relational and staging tables
-- ============================================================


-- 1. CUSTOMERS
CREATE TABLE customers (
    customer_id VARCHAR(20) PRIMARY KEY,
    country VARCHAR(50) NOT NULL,
    customer_age INTEGER,
    account_age_days INTEGER
);


-- 2. MERCHANTS
CREATE TABLE merchants (
    merchant_id VARCHAR(20) PRIMARY KEY,
    merchant_name VARCHAR(100) NOT NULL,
    merchant_category VARCHAR(50),
    merchant_country VARCHAR(50)
);


-- 3. TRANSACTIONS
CREATE TABLE transactions (
    transaction_id VARCHAR(20) PRIMARY KEY,

    customer_id VARCHAR(20) NOT NULL,
    merchant_id VARCHAR(20) NOT NULL,

    transaction_timestamp TIMESTAMP NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,

    transaction_type VARCHAR(30),
    payment_method VARCHAR(30),
    device_type VARCHAR(20),

    status VARCHAR(20) NOT NULL,
    failure_reason VARCHAR(100),

    is_international BOOLEAN,
    high_value_flag BOOLEAN,
    multiple_failures_flag BOOLEAN,
    risk_flag BOOLEAN,

    CONSTRAINT fk_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),

    CONSTRAINT fk_merchant
        FOREIGN KEY (merchant_id)
        REFERENCES merchants(merchant_id)
);


-- 4. STAGING TRANSACTIONS
-- Raw import table matching transactions.csv
CREATE TABLE staging_transactions (
    transaction_id VARCHAR(20),
    customer_id VARCHAR(20),
    merchant_id VARCHAR(20),
    transaction_timestamp TIMESTAMP,
    amount NUMERIC(12, 2),
    transaction_type VARCHAR(30),
    payment_method VARCHAR(30),
    device_type VARCHAR(20),
    status VARCHAR(20),
    failure_reason VARCHAR(100),

    country VARCHAR(50),
    customer_age INTEGER,
    account_age_days INTEGER,

    merchant_name VARCHAR(100),
    merchant_category VARCHAR(50),
    merchant_country VARCHAR(50),

    is_international BOOLEAN,
    high_value_flag BOOLEAN,
    multiple_failures_flag BOOLEAN,
    risk_flag BOOLEAN
);
