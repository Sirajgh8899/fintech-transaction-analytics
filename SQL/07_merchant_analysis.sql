-- ============================================================
-- FinTech Transaction Analytics
-- File: 07_merchant_analysis.sql
-- Purpose: Analyze merchant and category performance
-- ============================================================


-- 1. MERCHANT PERFORMANCE

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
    ) AS failure_rate_pct

FROM transactions t

JOIN merchants m
    ON t.merchant_id = m.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,
    m.merchant_country

ORDER BY transaction_value DESC;

-- 2. MERCHANTS WITH HIGHEST FAILURE RATES

SELECT
    m.merchant_id,
    m.merchant_name,
    m.merchant_category,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE t.status = 'Failed'
    ) AS failed_transactions,

    ROUND(
        100.0 * COUNT(*) FILTER (WHERE t.status = 'Failed')
        / COUNT(*),
        2
    ) AS failure_rate_pct

FROM transactions t

JOIN merchants m
    ON t.merchant_id = m.merchant_id

GROUP BY
    m.merchant_id,
    m.merchant_name,
    m.merchant_category

HAVING COUNT(*) >= 100

ORDER BY failure_rate_pct DESC

LIMIT 10;

-- 3. MERCHANT CATEGORY PERFORMANCE

SELECT
    m.merchant_category,

    COUNT(DISTINCT m.merchant_id) AS merchants,

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

JOIN merchants m
    ON t.merchant_id = m.merchant_id

GROUP BY m.merchant_category

ORDER BY transaction_value DESC;

-- 4. DOMESTIC VS INTERNATIONAL TRANSACTIONS

SELECT
    CASE
        WHEN t.is_international = TRUE THEN 'International'
        ELSE 'Domestic'
    END AS transaction_scope,

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

GROUP BY t.is_international

ORDER BY transaction_value DESC;