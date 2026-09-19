-- ============================================================
-- FinTech Transaction Analytics
-- File: 11_powerbi_views.sql
-- Purpose: Reporting views for Power BI
-- ============================================================


-- ============================================================
-- 1. TRANSACTION REPORTING VIEW
-- ============================================================

CREATE OR REPLACE VIEW vw_transaction_analysis AS

SELECT
    t.transaction_id,
    t.transaction_timestamp,

    -- Date dimensions
    t.transaction_timestamp::date AS transaction_date,
    DATE_TRUNC('month', t.transaction_timestamp)::date AS transaction_month,
    EXTRACT(YEAR FROM t.transaction_timestamp)::integer AS transaction_year,
    EXTRACT(MONTH FROM t.transaction_timestamp)::integer AS month_number,
    TO_CHAR(t.transaction_timestamp, 'Mon') AS month_name,
    TRIM(TO_CHAR(t.transaction_timestamp, 'Day')) AS day_name,
    EXTRACT(HOUR FROM t.transaction_timestamp)::integer AS transaction_hour,

    -- Transaction information
    t.amount,
    t.transaction_type,
    t.payment_method,
    t.device_type,
    t.status,
    t.failure_reason,

    -- Customer information
    t.customer_id,
    c.country AS customer_country,
    c.customer_age,
    c.account_age_days,

    -- Merchant information
    t.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.merchant_country,

    -- Geographic information
    t.is_international,

    CASE
        WHEN t.is_international = TRUE THEN 'International'
        ELSE 'Domestic'
    END AS transaction_scope,

    -- Risk information
    t.high_value_flag,
    t.multiple_failures_flag,
    t.risk_flag,

    CASE
        WHEN t.risk_flag = TRUE THEN 'Flagged'
        ELSE 'Not Flagged'
    END AS risk_status,

    -- Useful numeric BI fields
    CASE
        WHEN t.status = 'Successful' THEN 1
        ELSE 0
    END AS successful_transaction,

    CASE
        WHEN t.status = 'Failed' THEN 1
        ELSE 0
    END AS failed_transaction,

    CASE
        WHEN t.risk_flag = TRUE THEN 1
        ELSE 0
    END AS flagged_transaction,

    CASE
        WHEN t.risk_flag = TRUE THEN t.amount
        ELSE 0
    END AS flagged_transaction_value

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

JOIN merchants m
    ON t.merchant_id = m.merchant_id;