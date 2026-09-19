-- ============================================================
-- FinTech Transaction Analytics
-- File: 12_powerbi_summary_views.sql
-- Purpose: Summary reporting views for Power BI
-- ============================================================


-- ============================================================
-- 1. MONTHLY PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_monthly_performance AS

SELECT
    DATE_TRUNC('month', transaction_timestamp)::date AS month,
    COUNT(*) AS total_transactions,
    ROUND(SUM(amount), 2) AS transaction_value,
    ROUND(AVG(amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE status = 'Successful'
    ) AS successful_transactions,

    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'Successful')
        / COUNT(*),
        2
    ) AS success_rate_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions

GROUP BY DATE_TRUNC('month', transaction_timestamp);


-- ============================================================
-- 2. PAYMENT METHOD PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_payment_method_performance AS

SELECT
    payment_method,

    COUNT(*) AS total_transactions,

    ROUND(SUM(amount), 2) AS transaction_value,

    ROUND(AVG(amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'Successful')
        / COUNT(*),
        2
    ) AS success_rate_pct,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions

GROUP BY payment_method;


-- ============================================================
-- 3. COUNTRY PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_country_performance AS

SELECT
    c.country,

    COUNT(DISTINCT t.customer_id) AS active_customers,

    COUNT(*) AS total_transactions,

    ROUND(SUM(t.amount), 2) AS transaction_value,

    ROUND(AVG(t.amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE t.status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct,

    COUNT(*) FILTER (
        WHERE t.risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

GROUP BY c.country;


-- ============================================================
-- 4. MERCHANT PERFORMANCE
-- ============================================================

CREATE OR REPLACE VIEW vw_merchant_performance AS

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.merchant_country,

    COUNT(*) AS total_transactions,

    ROUND(SUM(t.amount), 2) AS transaction_value,

    ROUND(AVG(t.amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE t.status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct,

    COUNT(*) FILTER (
        WHERE t.risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions t

JOIN merchants m
    ON t.merchant_id = m.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.merchant_country;


-- ============================================================
-- 5. CUSTOMER RISK PROFILE
-- ============================================================

CREATE OR REPLACE VIEW vw_customer_risk_profile AS

SELECT
    t.customer_id,
    c.country,

    COUNT(*) AS total_transactions,

    ROUND(SUM(t.amount), 2) AS transaction_value,

    ROUND(AVG(t.amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE t.status = 'Failed'
    ) AS failed_transactions,

    COUNT(*) FILTER (
        WHERE t.high_value_flag = TRUE
    ) AS high_value_transactions,

    COUNT(*) FILTER (
        WHERE t.multiple_failures_flag = TRUE
    ) AS multiple_failure_transactions,

    COUNT(*) FILTER (
        WHERE t.risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

GROUP BY
    t.customer_id,
    c.country;