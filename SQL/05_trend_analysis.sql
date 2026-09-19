-- ============================================================
-- FinTech Transaction Analytics
-- File: 05_trend_analysis.sql
-- Purpose: Analyze transaction performance over time
-- ============================================================


-- 1. MONTHLY TRANSACTION PERFORMANCE

SELECT
    DATE_TRUNC('month', transaction_timestamp)::DATE AS month,

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
    ) AS failure_rate_pct

FROM transactions

GROUP BY 1

ORDER BY 1;

-- 2. DAILY TRANSACTION PERFORMANCE

SELECT
    transaction_timestamp::DATE AS transaction_date,

    COUNT(*) AS total_transactions,

    ROUND(SUM(amount), 2) AS transaction_value,

    COUNT(*) FILTER (
        WHERE status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct

FROM transactions

GROUP BY 1

ORDER BY 1;
