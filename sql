-- For each product in the database, calculate how many more orders where placed in 
-- each month compared to the previous month.

-- IMPORTANT! This is going to be a 2-day warmup! FOR NOW, assume that each product
-- has sales every month. Do the calculations so that you're comparing to the previous 
-- month where there were sales.
-- For example, product_id #1 has no sales for October 1996. So compare November 1996
-- to September 1996 (the previous month where there were sales):
-- So if there were 27 units sold in November and 20 in September, the resulting 
-- difference should be 27-7 = 7.
-- (Later on we will work towards filling in the missing months.)

-- BIG HINT: Look at the expected results, how do you convert the dates to the 
-- correct format (year and month)?

-- sum of overall product sold by each productid for comparison
SELECT
    od.productid
    ,SUM(od.quantity)

FROM 
    orderdetails AS od

GROUP BY
    1
ORDER BY
    2 DESC


----------
WITH sum_per_month AS(
SELECT
    od.productid
    ,EXTRACT(year FROM o.orderdate) as year 
    ,EXTRACT(month FROM o.orderdate) as month
    ,SUM(od.quantity) as total

FROM 
    orders as o
JOIN 
    orderdetails as od
ON o.orderid = od.orderid

GROUP BY
    1,2,3

ORDER BY
    1,2,3)

SELECT 
    *
    ,total - previous_month

FROM(

SELECT 
    *
    ,coalesce(lag(total,1) OVER()) as previous_month

FROM sum_per_month

ORDER BY 1,2,3,4) as last_month_total