-- ============================================================
-- FinTech Transaction Analytics
-- File: 02_load_data.sql
-- Purpose: Load CSV data and populate normalized tables
-- ============================================================


-- 1. LOAD CUSTOMERS
\copy customers (customer_id, country, customer_age, account_age_days) FROM 'data/customers.csv' WITH (FORMAT CSV, HEADER TRUE);


-- 2. LOAD MERCHANTS
\copy merchants (merchant_id, merchant_name, merchant_category, merchant_country) FROM 'data/merchants.csv' WITH (FORMAT CSV, HEADER TRUE);


-- 3. LOAD RAW TRANSACTIONS INTO STAGING
\copy staging_transactions FROM 'data/transactions.csv' WITH (FORMAT CSV, HEADER TRUE);


-- 4. TRANSFORM STAGING DATA INTO NORMALIZED TRANSACTIONS TABLE
INSERT INTO transactions (
    transaction_id,
    customer_id,
    merchant_id,
    transaction_timestamp,
    amount,
    transaction_type,
    payment_method,
    device_type,
    status,
    failure_reason,
    is_international,
    high_value_flag,
    multiple_failures_flag,
    risk_flag
)
SELECT
    transaction_id,
    customer_id,
    merchant_id,
    transaction_timestamp,
    amount,
    transaction_type,
    payment_method,
    device_type,
    status,
    NULLIF(failure_reason, ''),
    is_international,
    high_value_flag,
    multiple_failures_flag,
    risk_flag
FROM staging_transactions;
