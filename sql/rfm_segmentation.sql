USE ecommerce_db;

WITH raw_rfm AS (
    -- Calculating raw Recency, Frequency, and Monetary values per customer
    -- We use '2011-12-10'  as the reference point for Recency calculation
    SELECT 
        c.customer_id,
        DATEDIFF(
            (SELECT MAX(transaction_date) FROM fact_transactions), 
            MAX(f.transaction_date)
        ) AS recency_days,
        COUNT(DISTINCT f.invoice_id) AS frequency_count,
        SUM(f.line_total) AS monetary_value
    FROM dim_customers c
    JOIN fact_transactions f ON c.customer_id = f.customer_id
    GROUP BY c.customer_id
),

rfm_scores AS (
    -- Using NTILE() Window Functions to assign scores from 1 to 4 for R, F, and M
    -- NTILE(4) divides customers into 4 equal quartiles
    SELECT 
        customer_id,
        recency_days,
        frequency_count,
        monetary_value,
        -- Lower recency days = better score, so we reverse ordering for Recency NTILE
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency_count ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM raw_rfm
)

-- Step 3: Segment Customers into Strategic Business Groups based on RFM scores
SELECT 
    customer_id,
    recency_days,
    frequency_count,
    ROUND(monetary_value, 2) AS net_revenue,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_combined_score,
    CASE 
        WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN '1. Champions (Top Buyers)'
        WHEN r_score >= 3 AND f_score >= 3 THEN '2. Loyal Customers'
        WHEN r_score = 1 AND f_score >= 3 THEN '3. High Value At-Risk (Churn Warning)'
        WHEN r_score = 1 AND f_score <= 2 THEN '4. Lost / Churned Customers'
        ELSE '5. Recent / Average Buyers'
    END AS customer_segment
FROM rfm_scores
ORDER BY monetary_value DESC;




CREATE OR REPLACE VIEW view_customer_rfm_segments AS
WITH raw_rfm AS (
    SELECT 
        c.customer_id,
        DATEDIFF(
            (SELECT MAX(transaction_date) FROM fact_transactions), 
            MAX(f.transaction_date)
        ) AS recency_days,
        COUNT(DISTINCT CASE WHEN f.is_return = 0 THEN f.invoice_id END) AS frequency_count,
        SUM(f.line_total) AS monetary_value
    FROM dim_customers c
    JOIN fact_transactions f ON c.customer_id = f.customer_id
    GROUP BY c.customer_id
    -- Excluding customers who have a negative or zero overall net lifetime revenue
    HAVING SUM(f.line_total) > 0 
),
rfm_scores AS (
    SELECT 
        customer_id,
        recency_days,
        frequency_count,
        monetary_value,
        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(4) OVER (ORDER BY frequency_count ASC) AS f_score,
        NTILE(4) OVER (ORDER BY monetary_value ASC) AS m_score
    FROM raw_rfm
)
SELECT 
    customer_id,
    recency_days,
    frequency_count,
    ROUND(monetary_value, 2) AS net_revenue,
    r_score,
    f_score,
    m_score,
    CONCAT(r_score, f_score, m_score) AS rfm_combined_score,
    CASE 
        WHEN r_score = 4 AND f_score = 4 AND m_score = 4 THEN '1. Champions (Top Buyers)'
        WHEN r_score >= 3 AND f_score >= 3 THEN '2. Loyal Customers'
        WHEN r_score = 1 AND f_score >= 3 THEN '3. High Value At-Risk (Churn Warning)'
        WHEN r_score = 1 AND f_score <= 2 THEN '4. Lost / Churned Customers'
        ELSE '5. Recent / Average Buyers'
    END AS customer_segment
FROM rfm_scores;

SELECT * FROM view_customer_rfm_segments LIMIT 10;