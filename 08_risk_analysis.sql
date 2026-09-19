-- ============================================================
-- FinTech Transaction Analytics
-- File: 08_risk_analysis.sql
-- Purpose: Analyze flagged and potentially suspicious activity
-- ============================================================


-- 1. OVERALL RISK SUMMARY

SELECT
    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct,

    ROUND(
        SUM(amount) FILTER (WHERE risk_flag = TRUE),
        2
    ) AS flagged_transaction_value,

    ROUND(
        AVG(amount) FILTER (WHERE risk_flag = TRUE),
        2
    ) AS avg_flagged_transaction_value

FROM transactions;


-- 2. BREAK DOWN WHY TRANSACTIONS WERE FLAGGED

SELECT
    COUNT(*) FILTER (
        WHERE high_value_flag = TRUE
    ) AS high_value_transactions,

    COUNT(*) FILTER (
        WHERE multiple_failures_flag = TRUE
    ) AS multiple_failure_transactions,

    COUNT(*) FILTER (
        WHERE high_value_flag = TRUE
          AND multiple_failures_flag = TRUE
    ) AS both_conditions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS total_flagged_transactions

FROM transactions;


-- 3. RISK BY PAYMENT METHOD

SELECT
    payment_method,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct,

    ROUND(
        SUM(amount) FILTER (WHERE risk_flag = TRUE),
        2
    ) AS flagged_transaction_value

FROM transactions

GROUP BY payment_method

ORDER BY flagged_rate_pct DESC;


-- 4. RISK BY DEVICE

SELECT
    device_type,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct

FROM transactions

GROUP BY device_type

ORDER BY flagged_rate_pct DESC;


-- 5. RISK BY CUSTOMER COUNTRY

SELECT
    c.country,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct,

    ROUND(
        SUM(t.amount) FILTER (WHERE t.risk_flag = TRUE),
        2
    ) AS flagged_transaction_value

FROM transactions t

JOIN customers c
    ON t.customer_id = c.customer_id

GROUP BY c.country

ORDER BY flagged_rate_pct DESC;