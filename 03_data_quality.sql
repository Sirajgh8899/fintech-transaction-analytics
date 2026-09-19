-- ============================================================
-- FinTech Transaction Analytics
-- File: 03_data_quality.sql
-- Purpose: Validate completeness, uniqueness and integrity
-- ============================================================


-- 1. ROW COUNTS
SELECT 'customers' AS table_name, COUNT(*) AS row_count
FROM customers

UNION ALL

SELECT 'merchants', COUNT(*)
FROM merchants

UNION ALL

SELECT 'transactions', COUNT(*)
FROM transactions;


-- 2. CHECK DUPLICATE TRANSACTION IDs
SELECT
    transaction_id,
    COUNT(*) AS duplicate_count
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;


-- 3. CHECK IMPORTANT NULL VALUES
SELECT
    COUNT(*) FILTER (WHERE transaction_id IS NULL) AS missing_transaction_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE merchant_id IS NULL) AS missing_merchant_id,
    COUNT(*) FILTER (WHERE transaction_timestamp IS NULL) AS missing_timestamp,
    COUNT(*) FILTER (WHERE amount IS NULL) AS missing_amount,
    COUNT(*) FILTER (WHERE status IS NULL) AS missing_status
FROM transactions;


-- 4. CHECK TRANSACTION AMOUNTS
SELECT
    MIN(amount) AS minimum_amount,
    MAX(amount) AS maximum_amount,
    ROUND(AVG(amount), 2) AS average_amount
FROM transactions;


-- 5. CHECK TRANSACTION DATE RANGE
SELECT
    MIN(transaction_timestamp) AS first_transaction,
    MAX(transaction_timestamp) AS last_transaction
FROM transactions;


-- 6. CHECK STATUS VALUES
SELECT
    status,
    COUNT(*) AS transaction_count
FROM transactions
GROUP BY status
ORDER BY transaction_count DESC;


-- 7. FAILURE REASON BUSINESS-RULE CHECK
SELECT
    COUNT(*) FILTER (
        WHERE status = 'Failed'
        AND failure_reason IS NULL
    ) AS failed_without_reason,

    COUNT(*) FILTER (
        WHERE status = 'Successful'
        AND failure_reason IS NOT NULL
    ) AS successful_with_failure_reason
FROM transactions;


-- 8. CHECK FOR ORPHAN CUSTOMER REFERENCES
SELECT COUNT(*) AS orphan_customer_transactions
FROM transactions t
LEFT JOIN customers c
    ON t.customer_id = c.customer_id
WHERE c.customer_id IS NULL;


-- 9. CHECK FOR ORPHAN MERCHANT REFERENCES
SELECT COUNT(*) AS orphan_merchant_transactions
FROM transactions t
LEFT JOIN merchants m
    ON t.merchant_id = m.merchant_id
WHERE m.merchant_id IS NULL;