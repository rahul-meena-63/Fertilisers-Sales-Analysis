-- Raw staging table--
CREATE TABLE Fertilizers_Sales (
    TransactionID       VARCHAR(30) NOT NULL,
    Date                DATE NOT NULL,
    Year                SMALLINT NOT NULL,
    Month               TINYINT NOT NULL,
    Month_Name          VARCHAR(25) NOT NULL,
    Quarter             VARCHAR(10) NOT NULL,
    Season              VARCHAR(10) NOT NULL,
    State               VARCHAR(50) NOT NULL,
    District            VARCHAR(50) NOT NULL,
    Product             VARCHAR(50) NOT NULL,
    Category            VARCHAR(25) NOT NULL,
    Quantity_MT         DECIMAL(12, 2) NOT NULL,
    Unit_Price          DECIMAL(12, 2) NOT NULL,
    Discount_Pct        DECIMAL(5, 3) NOT NULL,
    Revenue             DECIMAL(18, 2) NOT NULL,
    COGS                DECIMAL(18, 2) NOT NULL,
    Gross_Profit        DECIMAL(18, 2) NOT NULL,
    Channel             VARCHAR(40) NOT NULL,
    SalesRep            VARCHAR(10) NOT NULL,
    CustomerType        VARCHAR(40) NOT NULL,
    ReturnFlag          VARCHAR(3) NOT NULL,
    PRIMARY KEY (TransactionID)
);




-- STEP 1: Null values in critical columns
SELECT 
    SUM(CASE WHEN TransactionID IS NULL THEN 1 ELSE 0 END) AS null_txn_id,
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END)    AS null_date,
    SUM(CASE WHEN Revenue < 0 THEN 1 ELSE 0 END)   AS negative_revenue,
    SUM(CASE WHEN Quantity_MT <= 0 THEN 1 ELSE 0 END)  AS zero_qty,
    COUNT(*)       AS total_rows
FROM Fertilizers_Sales


-- STEP 2: Duplicate transactions

SELECT TransactionID, COUNT(*) AS cnt
FROM Fertilizers_Sales
GROUP BY TransactionID HAVING COUNT(*) > 1

-- STEP 3: Revenue sanity (Revenue ≈ Qty * Unit_Price * (1 - Discount))
SELECT COUNT(*) AS revenue_mismatches
FROM Fertilizers_Sales
WHERE ABS(Revenue - (Quantity_MT * Unit_Price)) > 1;


----A) Annual Revenue and YoY Growth
WITH annual AS (
    SELECT Year, 
           ROUND(SUM(Revenue)/1e6,2)   AS revenue_mn,
           CONCAT(CAST(ROUND(SUM(Gross_Profit)/1e6,2) AS VARCHAR(50)),' M') AS profit_mn,
           SUM(Quantity_MT)     AS volume_mt
    FROM Fertilizers_Sales WHERE ReturnFlag='No'
    GROUP BY Year
)
SELECT Year, revenue_mn, profit_mn, volume_mt,
    ROUND((revenue_mn - LAG(revenue_mn) OVER(ORDER BY Year))
          / LAG(revenue_mn) OVER(ORDER BY Year) * 100, 1) AS yoy_growth_pct
FROM annual ORDER BY Year;


-- B) Top 5 Products by Revenue
SELECT TOP 5 Product, Category,
   CONCAT(CAST( ROUND(SUM(Revenue)/1e6,2) AS VARCHAR(50)),' M')  AS revenue_mn,
   SUM(Quantity_MT)                                              AS volume_mt,
   CAST( ROUND(AVG(Gross_Profit/Revenue)*100,1) AS DECIMAL(5,1)) AS avg_margin_pct
FROM Fertilizers_Sales WHERE ReturnFlag='No'
GROUP BY Product, Category
ORDER BY revenue_mn DESC 


---C)  Revenue by State
SELECT State,
    CONCAT(CAST(ROUND(SUM(Revenue)/1e6,2) AS VARCHAR(50)),' M')     AS revenue_mn,
    SUM(Quantity_MT)                    AS volume_mt,
    CAST(ROUND(AVG(Discount_Pct)*100,1) AS DECIMAL(5,1)) AS avg_discount_pct,
    RANK() OVER(ORDER BY SUM(Revenue) DESC) AS revenue_rank
FROM Fertilizers_Sales WHERE ReturnFlag='No'
GROUP BY State


-- D) Seasonal Sales Pattern
SELECT Season, Quarter, Month,Month_Name,
    COUNT(*)                       AS transactions,
    CONCAT(CAST(ROUND(SUM(Revenue)/1e6,2)  AS VARCHAR(50)),' M')    AS revenue_mn,
    ROUND(SUM(Quantity_MT)/1000,1) AS volume_k_mt
FROM Fertilizers_Sales WHERE ReturnFlag='No'
GROUP BY Season, Quarter, Month,Month_Name ORDER BY Month;

-- E) Channel Efficiency Analysis
SELECT Channel,
    COUNT(*)                               AS orders,
    ROUND(SUM(Revenue)/1e6,2)             AS revenue_mn,
    ROUND(AVG(Discount_Pct)*100,2)        AS avg_discount_pct,
    ROUND(SUM(Gross_Profit)/SUM(Revenue)*100,1) AS gross_margin_pct,
    SUM(CASE WHEN ReturnFlag='Yes' THEN 1 ELSE 0 END) AS returns
FROM Fertilizers_Sales
GROUP BY Channel ORDER BY revenue_mn DESC;

-- F) SalesRep Leaderboard (Top 10)
SELECT TOP 10 SalesRep,
    COUNT(*)                       AS deals,
    ROUND(SUM(Revenue)/1e6,2)      AS revenue_mn,
    ROUND(AVG(Discount_Pct)*100,1) AS avg_discount_pct,
    SUM(CASE WHEN ReturnFlag='Yes' THEN 1 ELSE 0 END) AS returns,
    RANK() OVER(ORDER BY SUM(Revenue) DESC) AS rank_rev
FROM Fertilizers_Sales WHERE ReturnFlag='No'
GROUP BY SalesRep ORDER BY rank_rev;


-- G) Customer Segment Profitability
SELECT CustomerType,
    COUNT(*)                               AS transactions,
    ROUND(SUM(Revenue)/1e6,2)             AS revenue_mn,
    ROUND(SUM(Gross_Profit)/SUM(Revenue)*100,1) AS margin_pct,
    ROUND(SUM(Revenue)/COUNT(*),0)        AS avg_order_value
FROM Fertilizers_Sales WHERE ReturnFlag='No'
GROUP BY CustomerType ORDER BY revenue_mn DESC;

-- H) Rolling 3-Month Revenue (Window Function)
SELECT Date, Revenue,
    ROUND(AVG(Revenue) OVER(
        ORDER BY Date ROWS BETWEEN 89 PRECEDING AND CURRENT ROW
    ),2) AS rolling_90d_avg
FROM Fertilizers_Sales WHERE ReturnFlag='No'
ORDER BY Date;

-- I) Return Analysis by Product
SELECT Product, Category,
    COUNT(*)                                          AS total_sales,
    SUM(CASE WHEN ReturnFlag='Yes' THEN 1 ELSE 0 END) AS returns,
    ROUND(SUM(CASE WHEN ReturnFlag='Yes' THEN 1 ELSE 0 END)/COUNT(*)*100,1) AS return_rate_pct
FROM Fertilizers_Sales
GROUP BY Product, Category ORDER BY return_rate_pct DESC

-- J) Cohort: First Purchase Month Retention
WITH first_buy AS (
    SELECT District, MIN(FORMAT(Date,'YYYY-MMM')) AS cohort_month
    FROM Fertilizers_Sales GROUP BY District
)
SELECT f.cohort_month, COUNT(DISTINCT s.District) AS active_districts
FROM first_buy f
JOIN Fertilizers_Sales s ON s.District=f.District
GROUP BY f.cohort_month ORDER BY f.cohort_month
