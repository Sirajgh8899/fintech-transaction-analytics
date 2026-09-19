-- ============================================================
-- FinTech Transaction Analytics
-- File: 09_advanced_risk_analysis.sql
-- Purpose: Customer-level risk concentration analysis
-- ============================================================


-- 1. CUSTOMERS WITH FLAGGED TRANSACTIONS

SELECT
    COUNT(DISTINCT customer_id) AS total_customers,

    COUNT(DISTINCT customer_id) FILTER (
        WHERE risk_flag = TRUE
    ) AS customers_with_flagged_activity,

    ROUND(
        100.0 *
        COUNT(DISTINCT customer_id) FILTER (WHERE risk_flag = TRUE)
        / COUNT(DISTINCT customer_id),
        2
    ) AS pct_customers_with_flagged_activity

FROM transactions;


-- 2. TOP CUSTOMERS BY NUMBER OF FLAGGED TRANSACTIONS

SELECT
    customer_id,

    COUNT(*) AS total_transactions,

    COUNT(*) FILTER (
        WHERE risk_flag = TRUE
    ) AS flagged_transactions,

    ROUND(
        100.0 *
        COUNT(*) FILTER (WHERE risk_flag = TRUE)
        / COUNT(*),
        2
    ) AS flagged_rate_pct,

    ROUND(
        SUM(amount) FILTER (WHERE risk_flag = TRUE),
        2
    ) AS flagged_transaction_value

FROM transactions

GROUP BY customer_id

HAVING COUNT(*) FILTER (WHERE risk_flag = TRUE) > 0

ORDER BY flagged_transactions DESC

LIMIT 20;


-- 3. DISTRIBUTION OF FLAGGED ACTIVITY

WITH customer_risk AS (

    SELECT
        customer_id,

        COUNT(*) FILTER (
            WHERE risk_flag = TRUE
        ) AS flagged_transactions

    FROM transactions

    GROUP BY customer_id
)

SELECT
    flagged_transactions,
    COUNT(*) AS customers

FROM customer_risk

WHERE flagged_transactions > 0

GROUP BY flagged_transactions

ORDER BY flagged_transactions;


-- 4. TOP 10% OF FLAGGED CUSTOMERS:
-- WHAT SHARE OF ALL FLAGGED TRANSACTIONS DO THEY REPRESENT?

WITH customer_risk AS (

    SELECT
        customer_id,

        COUNT(*) FILTER (
            WHERE risk_flag = TRUE
        ) AS flagged_transactions

    FROM transactions

    GROUP BY customer_id
),

flagged_customers AS (

    SELECT
        customer_id,
        flagged_transactions,

        ROW_NUMBER() OVER (
            ORDER BY flagged_transactions DESC
        ) AS customer_rank,

        COUNT(*) OVER () AS total_flagged_customers

    FROM customer_risk

    WHERE flagged_transactions > 0
)

SELECT
    COUNT(*) FILTER (
        WHERE customer_rank <= CEIL(total_flagged_customers * 0.10)
    ) AS customers_in_top_10_pct,

    SUM(flagged_transactions) FILTER (
        WHERE customer_rank <= CEIL(total_flagged_customers * 0.10)
    ) AS flags_from_top_10_pct,

    SUM(flagged_transactions) AS total_flags,

    ROUND(
        100.0 *
        SUM(flagged_transactions) FILTER (
            WHERE customer_rank <= CEIL(total_flagged_customers * 0.10)
        )
        / SUM(flagged_transactions),
        2
    ) AS share_of_flags_from_top_10_pct

FROM flagged_customers;


-- 5. HIGH-RISK CUSTOMER PROFILE
-- Compare customers with and without flagged activity

WITH customer_summary AS (

    SELECT
        customer_id,

        COUNT(*) AS total_transactions,

        SUM(amount) AS total_value,

        AVG(amount) AS avg_transaction_value,

        COUNT(*) FILTER (
            WHERE status = 'Failed'
        ) AS failed_transactions,

        COUNT(*) FILTER (
            WHERE risk_flag = TRUE
        ) AS flagged_transactions

    FROM transactions

    GROUP BY customer_id
)

SELECT
    CASE
        WHEN flagged_transactions > 0
            THEN 'Flagged Customers'
        ELSE 'Non-Flagged Customers'
    END AS customer_group,

    COUNT(*) AS customers,

    ROUND(
        AVG(total_transactions),
        2
    ) AS avg_transactions_per_customer,

    ROUND(
        AVG(total_value),
        2
    ) AS avg_total_value_per_customer,

    ROUND(
        AVG(avg_transaction_value),
        2
    ) AS avg_transaction_value,

    ROUND(
        AVG(failed_transactions),
        2
    ) AS avg_failed_transactions

FROM customer_summary

GROUP BY customer_group

ORDER BY customer_group;
