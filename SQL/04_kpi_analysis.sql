-- ============================================================
-- FinTech Transaction Analytics
-- File: 04_kpi_analysis.sql
-- Purpose: Calculate core transaction and payment KPIs
-- ============================================================


-- 1. OVERALL TRANSACTION KPIs

SELECT
    COUNT(*) AS total_transactions,

    ROUND(SUM(amount), 2) AS total_transaction_value,

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
    ) AS failure_rate_pct

FROM transactions;

-- 2. PAYMENT METHOD PERFORMANCE

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
    ) AS failure_rate_pct

FROM transactions

GROUP BY payment_method

ORDER BY failure_rate_pct DESC;

-- 3. FAILURE REASON ANALYSIS

SELECT
    failure_reason,
    COUNT(*) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (),
        2
    ) AS share_of_failures_pct

FROM transactions

WHERE status = 'Failed'

GROUP BY failure_reason

ORDER BY failed_transactions DESC;

-- 4. FAILURE REASONS BY PAYMENT METHOD

SELECT
    payment_method,
    failure_reason,
    COUNT(*) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY payment_method),
        2
    ) AS share_within_payment_method_pct

FROM transactions

WHERE status = 'Failed'

GROUP BY
    payment_method,
    failure_reason

ORDER BY
    payment_method,
    failed_transactions DESC;
