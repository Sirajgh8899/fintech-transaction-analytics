-- ============================================================
-- FinTech Transaction Analytics
-- File: 10_risk_validation.sql
-- Purpose: Validate synthetic risk flag relationships
-- ============================================================


-- 1. CROSS-TAB OF RISK INDICATORS

SELECT
    high_value_flag,
    multiple_failures_flag,
    risk_flag,
    COUNT(*) AS transactions
FROM transactions
GROUP BY
    high_value_flag,
    multiple_failures_flag,
    risk_flag
ORDER BY
    high_value_flag,
    multiple_failures_flag,
    risk_flag;


-- 2. MULTIPLE-FAILURE FLAG BUT NOT RISK FLAG

SELECT
    COUNT(*) AS multiple_failure_not_risk
FROM transactions
WHERE multiple_failures_flag = TRUE
  AND risk_flag = FALSE;


-- 3. RISK FLAG WITHOUT OTHER TWO INDICATORS

SELECT
    COUNT(*) AS risk_without_other_flags
FROM transactions
WHERE risk_flag = TRUE
  AND high_value_flag = FALSE
  AND multiple_failures_flag = FALSE;


-- 4. HIGH VALUE BUT NOT RISK FLAG

SELECT
    COUNT(*) AS high_value_not_risk
FROM transactions
WHERE high_value_flag = TRUE
  AND risk_flag = FALSE;


-- 5. EXAMPLE FLAGGED TRANSACTIONS

SELECT
    transaction_id,
    customer_id,
    transaction_timestamp,
    amount,
    payment_method,
    status,
    is_international,
    high_value_flag,
    multiple_failures_flag,
    risk_flag
FROM transactions
WHERE risk_flag = TRUE
ORDER BY amount DESC
LIMIT 20;