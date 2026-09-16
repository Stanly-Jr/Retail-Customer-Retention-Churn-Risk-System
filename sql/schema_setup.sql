use ecommerce_db;

CREATE TABLE dim_customers AS 
SELECT
	  `Customer ID` AS customer_id,
      MIN(InvoiceDate) AS first_prchase_date,
      MAX(InvoiceDate) AS last_purchase_date,
      COUNT(DISTINCT Invoice) AS total_lifetime_orders
FROM stg_transactions
GROUP BY `Customer ID`;

ALTER TABLE dim_customers ADD PRIMARY KEY (customer_id);

CREATE TABLE dim_products AS
SELECT 
    StockCode AS stock_code,
    MAX(Description) 
FROM stg_transactions
WHERE StockCode IS NOT NULL
GROUP BY StockCode;

ALTER TABLE dim_products 
MODIFY COLUMN stock_code VARCHAR(50);

ALTER TABLE dim_products 
ADD PRIMARY KEY (stock_code);


CREATE TABLE fact_transactions AS
SELECT 
    Invoice AS invoice_id,
    `Customer ID` AS customer_id,
    StockCode AS stock_code,
    InvoiceDate AS transaction_date,
    Quantity AS quantity,
    Price AS unit_price,
    Total_Value AS line_total,
    Is_Return AS is_return
FROM stg_transactions;

ALTER TABLE fact_transactions 
MODIFY COLUMN stock_code VARCHAR(50);

ALTER TABLE fact_transactions 
MODIFY COLUMN transaction_date DATETIME;

-- Index key columns for high-performance join execution in Power BI / SQL queries
CREATE INDEX idx_cust_id ON fact_transactions(customer_id);
CREATE INDEX idx_stock_code ON fact_transactions(stock_code);
CREATE INDEX idx_trans_date ON fact_transactions(transaction_date);


SELECT COUNT(*) FROM stg_transactions;
SELECT COUNT(*) FROM fact_transactions;
SELECT COUNT(*) FROM dim_customers;
SELECT COUNT(*) FROM dim_products;
