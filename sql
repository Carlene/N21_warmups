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


---------- Difference in sold quantity each month per product
WITH sum_per_id AS(
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
    ,coalesce(total - previous_month, 0)
FROM
    (SELECT 
        *
        ,lag(total,1) OVER(PARTITION BY productid) as previous_month

    FROM sum_per_id

    ORDER BY 1,2,3,4) as last_month_total

---- Filling in missing months

-- SELECT * 
-- FROM generate_series(1,12) as months
-- JOIN(
-- SELECT * 
-- FROM generate_series(2014,2016) as years) AS months_years


WITH gm as(
    SELECT 
        od.productid as productid
        ,generate_series(min(o.orderdate)::date
                        ,max(o.orderdate)::date
                        ,interval '1 month') as gs
        ,SUM(od.quantity) as total

    FROM  
        orders as o
    JOIN 
        orderdetails as od
    ON o.orderid = od.orderid

    GROUP BY
        1, od.quantity

    ORDER BY
        1,2
    )

SELECT
    gm.productid
    ,EXTRACT(year FROM gm.gs) as year 
    ,EXTRACT(month FROM gm.gs) as month
    ,gm.total

FROM
    gm

GROUP BY
    1, 2, 3, 4

ORDER BY 
    1, 2, 3
