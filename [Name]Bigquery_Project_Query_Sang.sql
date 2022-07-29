-- Big project for SQL
-- Link instruction: https://docs.google.com/spreadsheets/d/1WnBJsZXj_4FDi2DyfLH1jkWtfTridO2icWbWCh7PLs8/edit#gid=0


-- Query 01: calculate total visit, pageview, transaction and revenue for Jan, Feb and March 2017 order by month
#standardSQL
SELECT
date,
SUM(totals.visits) AS visits,
SUM(totals.pageviews) AS pageviews,
SUM(totals.transactions) AS transactions,
SUM(totals.transactionRevenue)/1000000 AS revenue
FROM `bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
_TABLE_SUFFIX BETWEEN '20170101' AND '20170331'
GROUP BY date
ORDER BY date ASC




-- Query 02: Bounce rate per traffic source in July 2017
#standardSQL
SELECT
source,
total_visits,
total_no_of_bounces,
( ( total_no_of_bounces / total_visits ) * 100 ) AS bounce_rate
FROM (
SELECT
trafficSource.source AS source,
COUNT ( trafficSource.source ) AS total_visits,
SUM ( totals.bounces ) AS total_no_of_bounces
FROM
TABLE_DATE_RANGE( [bigquery-public-data.google_analytics_sample.ga_sessions_],
TIMESTAMP('2017-07-01'), TIMESTAMP('2017-07-31') )
GROUP BY
source )
ORDER BY
total_visits DESC

-- Query 3: Revenue by traffic source by week, by month in June 2017


--Query 04: Average number of product pageviews by purchaser type (purchasers vs non-purchasers) in June, July 2017. Note: totals.transactions >=1 for purchaser and totals.transactions is null for non-purchaser
#standardSQL
SELECT
( SUM(total_pagesviews_per_user) / COUNT(users) ) AS avg_pageviews_per_user
FROM
SELECT
fullVisitorId AS users,
SUM(totals.pageviews) AS total_pagesviews_per_user
FROM`bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
_TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
AND
totals.transactions >=1
GROUP BY
users )



-- Query 05: Average number of transactions per user that made a purchase in July 2017
#standardSQL
SELECT
(SUM (total_transactions_per_user) / COUNT(fullVisitorId) ) AS avg_total_transactions_per_user
FROM (
SELECT
fullVisitorId,
SUM (totals.transactions) AS total_transactions_per_user
FROM
`bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
_TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
AND totals.transactions IS NOT NULL
GROUP BY
fullVisitorId )

-- Query 06: Average amount of money spent per session
#standardSQL
SELECT
( SUM(total_transactionrevenue_per_user) / SUM(total_visits_per_user) ) AS
avg_revenue_by_user_per_visit
FROM (
SELECT
fullVisitorId,
SUM( totals.visits ) AS total_visits_per_user,
SUM( totals.transactionRevenue ) AS total_transactionrevenue_per_user
FROM
`bigquery-public-data.google_analytics_sample.ga_sessions_*`
WHERE
_TABLE_SUFFIX BETWEEN '20170701' AND '20170731'
AND
totals.visits > 0
AND totals.transactions >= 1
AND totals.transactionRevenue IS NOT NULL
GROUP BY
fullVisitorId )


-- Query 07: Products purchased by customers who purchased product A (Classic Ecommerce)
#standardSQL
SELECT hits.item.productName AS other_purchased_products, COUNT(hits.item.productName) AS quantity
FROM [‘Dataset Name’ ]
WHERE fullVisitorId IN (
  SELECT fullVisitorId
  FROM [‘Dataset Name’ ]
  WHERE hits.item.productName CONTAINS 'Product Item Name A'
   AND totals.transactions>=1
  GROUP BY fullVisitorId )
 AND hits.item.productName IS NOT NULL
 AND hits.item.productName != 'Product Item Name A'
GROUP BY other_purchased_products
ORDER BY quantity DESC;


--Query 08: Calculate cohort map from pageview to addtocart to purchase in last 3 month. For example, 100% pageview then 40% add_to_cart and 10% purchase.
#standardSQL
