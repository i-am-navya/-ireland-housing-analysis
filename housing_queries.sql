
-- Irish Property Price Register - SQL Analysis
-- Author: Navya Zacharia
-- Dataset: propertypriceregister.ie

-- Query 1: National Average Price and Transaction Volume by Year
SELECT 
    Year,
    COUNT(*) as total_transactions,
    ROUND(AVG(Price), 0) as avg_price
FROM transactions
GROUP BY Year
ORDER BY Year;

-- Query 2: Average Price by County (Latest Year)
SELECT 
    County,
    COUNT(*) as total_transactions,
    ROUND(AVG(Price), 0) as avg_price,
    ROUND(MIN(Price), 0) as min_price,
    ROUND(MAX(Price), 0) as max_price
FROM transactions
WHERE Year = (SELECT MAX(Year) FROM transactions)
GROUP BY County
ORDER BY avg_price DESC;

-- Query 3: Year on Year Price Growth (CTE version)
WITH yearly_prices AS (
    SELECT
        Year,
        AVG(Price) as avg_price
    FROM transactions
    GROUP BY Year
)
SELECT
    Year,
    ROUND(avg_price, 0) as avg_price,
    ROUND(avg_price - LAG(avg_price) OVER (ORDER BY Year), 0) as yoy_change,
    ROUND(
        (avg_price - LAG(avg_price) OVER (ORDER BY Year))
        / LAG(avg_price) OVER (ORDER BY Year) * 100,
        1
    ) as yoy_pct_change
FROM yearly_prices
ORDER BY Year;

-- Query 4: Dublin vs National Average Price by Year
SELECT 
    Year,
    ROUND(AVG(CASE WHEN County = 'Dublin' THEN Price END), 0) as dublin_avg,
    ROUND(AVG(Price), 0) as national_avg,
    ROUND(AVG(CASE WHEN County = 'Dublin' THEN Price END) - AVG(Price), 0) as dublin_premium
FROM transactions
GROUP BY Year
ORDER BY Year;

-- Query 5: New Build vs Second-Hand Price by Year
SELECT 
    Year,
    ROUND(AVG(CASE WHEN [Property Type] = 'New Build' THEN Price END), 0) as new_build_avg,
    ROUND(AVG(CASE WHEN [Property Type] = 'Second-Hand' THEN Price END), 0) as second_hand_avg,
    ROUND(AVG(CASE WHEN [Property Type] = 'New Build' THEN Price END) - 
          AVG(CASE WHEN [Property Type] = 'Second-Hand' THEN Price END), 0) as new_build_premium
FROM transactions
GROUP BY Year
ORDER BY Year;

-- Query 6: Top 10 Counties by Transaction Volume
SELECT 
    County,
    COUNT(*) as total_transactions,
    ROUND(AVG(Price), 0) as avg_price,
    ROUND(MIN(Price), 0) as min_price,
    ROUND(MAX(Price), 0) as max_price
FROM transactions
GROUP BY County
ORDER BY total_transactions DESC
LIMIT 10;

-- Query 7: Price Band Distribution
SELECT 
    CASE 
        WHEN Price < 100000 THEN 'Under €100k'
        WHEN Price < 200000 THEN '€100k - €200k'
        WHEN Price < 300000 THEN '€200k - €300k'
        WHEN Price < 400000 THEN '€300k - €400k'
        WHEN Price < 500000 THEN '€400k - €500k'
        ELSE 'Over €500k'
    END as price_band,
    COUNT(*) as transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions), 1) as pct_of_total
FROM transactions
GROUP BY price_band
ORDER BY MIN(Price);

-- Query 8: Monthly Seasonality Analysis
SELECT 
    Month,
    COUNT(*) as total_transactions,
    ROUND(AVG(Price), 0) as avg_price
FROM transactions
GROUP BY Month
ORDER BY Month;

-- Query 9: County Price Growth Ranking (2015 to 2025)
SELECT 
    a.County,
    ROUND(a.avg_price_2015, 0) as avg_price_2015,
    ROUND(b.avg_price_2025, 0) as avg_price_2025,
    ROUND(b.avg_price_2025 - a.avg_price_2015, 0) as absolute_growth,
    ROUND((b.avg_price_2025 - a.avg_price_2015) / a.avg_price_2015 * 100, 1) as pct_growth
FROM 
    (SELECT County, AVG(Price) as avg_price_2015 
     FROM transactions WHERE Year = 2015 
     GROUP BY County) a
JOIN 
    (SELECT County, AVG(Price) as avg_price_2025 
     FROM transactions WHERE Year = 2025 
     GROUP BY County) b
ON a.County = b.County
ORDER BY pct_growth DESC;

-- Query 10: Affordability Analysis by County
SELECT 
    County,
    COUNT(*) as total_transactions,
    SUM(CASE WHEN Price < 300000 THEN 1 ELSE 0 END) as under_300k,
    ROUND(SUM(CASE WHEN Price < 300000 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) as pct_under_300k,
    ROUND(AVG(Price), 0) as avg_price
FROM transactions
WHERE Year = (SELECT MAX(Year) FROM transactions)
GROUP BY County
ORDER BY pct_under_300k DESC;

-- Query 11: County Price Ranking Using CTE and RANK()
WITH county_avg AS (
    SELECT
        County,
        COUNT(*) as total_transactions,
        ROUND(AVG(Price), 0) as avg_price
    FROM transactions
    GROUP BY County
),
county_ranked AS (
    SELECT
        County,
        total_transactions,
        avg_price,
        RANK() OVER (ORDER BY avg_price DESC) as price_rank
    FROM county_avg
)
SELECT *
FROM county_ranked
ORDER BY price_rank;

-- Query 12: Top 3 Most Expensive Counties Per Year Using ROW_NUMBER()
WITH county_year_avg AS (
    SELECT
        Year,
        County,
        ROUND(AVG(Price), 0) as avg_price,
        COUNT(*) as transactions
    FROM transactions
    GROUP BY Year, County
),
ranked AS (
    SELECT
        Year,
        County,
        avg_price,
        transactions,
        ROW_NUMBER() OVER (PARTITION BY Year ORDER BY avg_price DESC) as rank_in_year
    FROM county_year_avg
)
SELECT *
FROM ranked
WHERE rank_in_year <= 3
ORDER BY Year, rank_in_year;

-- Query 13: RANK vs DENSE_RANK vs ROW_NUMBER Demonstration
WITH county_avg AS (
    SELECT
        County,
        ROUND(AVG(Price), 0) as avg_price
    FROM transactions
    WHERE Year = (SELECT MAX(Year) FROM transactions)
    GROUP BY County
)
SELECT
    County,
    avg_price,
    ROW_NUMBER() OVER (ORDER BY avg_price DESC) as row_number,
    RANK()       OVER (ORDER BY avg_price DESC) as rank,
    DENSE_RANK() OVER (ORDER BY avg_price DESC) as dense_rank
FROM county_avg
ORDER BY avg_price DESC;

-- Query 14: 3-Year Rolling Average Price
WITH yearly_prices AS (
    SELECT
        Year,
        AVG(Price) AS avg_price
    FROM transactions
    GROUP BY Year
)
SELECT
    Year,
    ROUND(avg_price, 0) AS avg_price,
    ROUND(
        AVG(avg_price) OVER (
            ORDER BY Year
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        0
    ) AS rolling_3yr_avg
FROM yearly_prices
ORDER BY Year;
