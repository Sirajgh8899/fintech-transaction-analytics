-- ============================================================
-- FinTech Transaction Analytics
-- File: 06_customer_analysis.sql
-- Purpose: Analyze customer behavior and activity
-- ============================================================


-- 1. CUSTOMER ACTIVITY SUMMARY

SELECT
    COUNT(DISTINCT customer_id) AS active_customers,

    ROUND(
        COUNT(*)::NUMERIC /
        COUNT(DISTINCT customer_id),
        2
    ) AS avg_transactions_per_customer,

    ROUND(
        SUM(amount) /
        COUNT(DISTINCT customer_id),
        2
    ) AS avg_value_per_customer

FROM transactions;


-- 2. TOP 10 CUSTOMERS BY TRANSACTION VALUE

SELECT
    customer_id,

    COUNT(*) AS total_transactions,

    ROUND(SUM(amount), 2) AS total_transaction_value,

    ROUND(AVG(amount), 2) AS average_transaction_value,

    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions

FROM transactions

GROUP BY customer_id

ORDER BY total_transaction_value DESC

LIMIT 10;


-- 3. CUSTOMER PERFORMANCE BY COUNTRY

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
    ) AS failure_rate_pct

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

GROUP BY c.country

ORDER BY transaction_value DESC;

-- 4. CUSTOMER RISK PROFILE

SELECT
    customer_id,

    COUNT(*) AS total_transactions,

    ROUND(SUM(amount), 2) AS total_transaction_value,

    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,

    COUNT(*) FILTER (
        WHERE high_value_flag = TRUE
    ) AS high_value_transactions,

    COUNT(*) FILTER (
        WHERE multiple_failures_flag = TRUE
    ) AS multiple_failure_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_transaction_rate_pct

FROM transactions

GROUP BY customer_id

HAVING COUNT(*) FILTER (
    WHERE risk_flag = TRUE
) > 0

ORDER BY flagged_transactions DESC,
         flagged_transaction_rate_pct DESC

LIMIT 20;
