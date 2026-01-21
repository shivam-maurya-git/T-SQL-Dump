

--Q.  Write a query to find consecutive days where sales were above a threshold. 

WITH orders AS (SELECT invoice_date,SUM(quantity) AS order_count
FROM sales
GROUP BY invoice_date
HAVING SUM(quantity)>300
),

date_gap AS ( SELECT invoice_date, DATEADD(DAY,-ROW_NUMBER() OVER(ORDER BY invoice_date),invoice_date) As date_diff
FROM orders)

SELECT MIN(invoice_date) AS start_date, MAX(invoice_date) AS end_date, COUNT(*) AS consecutive_days
FROM date_gap
GROUP BY date_diff;

-- Write a query to concatenate employee names in each department (string aggregation).
SELECT JOB_ID,STRING_AGG(FIRST_NAME,',')

FROM employees

GROUP BY JOB_ID;



--Q. Write a recursive query to list all ancestors (managers) of a given employee. 

WITH x AS (
SELECT * FROM reporting_chain
WHERE employee_id=10

UNION ALL

SELECT y.employee_id,y.employee_name,y.manager_id,y.title
FROM reporting_chain AS y
JOIN x
ON x.manager_id = y.employee_id)

SELECT * FROM x

--Q.  Calculate the median salary by department using window functions. 

SELECT *, PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY Salary) OVER(PARTITION BY JOB_ID)
FROM employees
ORDER BY JOB_ID DESC

--Q. Write a query to find the first purchase date and last purchase date for each customer, including customers who never purchased anything. 

SELECT c.Customer_ID,MIN(s.Sale_Date) AS start_date, MAX(s.Sale_Date) AS end_date
FROM sample_customer AS c
LEFT JOIN sample_sales AS s
ON c.Customer_ID = s.Customer_ID
GROUP BY c.Customer_ID;

--Q.  Find the percentage difference between each month’s total sales and the previous month’s total sales.

WITH x AS (
SELECT MONTH(Sale_Date) AS month,
COUNT(*) AS total_sales
FROM sample_sales
GROUP BY MONTH(Sale_Date)
),

y AS (SELECT x.month, x.total_sales,total_sales - LAG(x.total_sales) OVER(ORDER BY month) AS diff
FROM x)

SELECT y.month, CAST(y.diff*100/y.total_sales AS decimal(10,2)) AS sale_change
FROM y;

SELECT * FROM sales;

--Q. Generate a report that shows sales and sales growth percentage compared to the same month last year.

WITH x AS (SELECT YEAR(invoice_date) AS year, MONTH(invoice_date) As month, SUM(quantity) As total_sales FROM sales
GROUP BY 
YEAR(invoice_date), MONTH(invoice_date)),

y AS (SELECT *, CAST(total_sales-
LAG(total_sales) OVER(PARTITION BY month ORDER BY year) AS decimal(6,2)) AS diff
FROM x)

SELECT y.year,y.month,y.total_sales, y.diff, CAST(ROUND(y.diff*100/y.total_sales,2) AS decimal(7,3))  AS sale_change
FROM y;
use Company;
SELECT * from sales;


--Q. Calculate the total revenue for each customer, and rank them from highest to lowest spender.

WITH x AS (SELECT c.Customer_ID, SUM(s.Sale_Amount) AS total_spend
from sample_customer AS c
LEFT JOIN sample_sales AS s
ON c.Customer_ID = s.Customer_ID
GROUP BY c.Customer_ID)

SELECT *, DENSE_RANK() OVER(ORDER BY total_spend DESC) As spend_rank
FROM x;

--Q. Write a query to find the top 3 products with the highest total sales amount each month.

WITH x as (SELECT 
YEAR(invoice_date) AS year, MONTH(invoice_date) AS month,category, SUM(quantity*price) AS total_rev
FROM sales
GROUP BY YEAR(invoice_date), MONTH(invoice_date), category)

SELECT * FROM (SELECT *,
DENSE_RANK() OVER(PARTITION BY year, month ORDER BY total_rev DESC) As sale_rank 
FROM x) As y
WHERE y.sale_rank<=3;

--Q. Write a recursive query to list all descendants of a manager in an organizational hierarchy.

WITH x AS (SELECT
* FROM reporting_chain
WHERE employee_id = 4

UNION ALL

SELECT y.employee_id,y.employee_name, y.manager_id,y.title 
FROM reporting_chain AS y
JOIN x
ON x.employee_id = y.manager_id)

SELECT * FROM x;

--Q. Calculate a 3-month moving average of monthly sales per product. 


WITH x AS (SELECT Product_Id, MONTH(Sale_Date) AS month, SUM(Unit_Price*Quantity_Sold) As total_Sale
FROM sales_data
GROUP BY Product_Id, MONTH(Sale_Date))

SELECT *,
AVG(total_Sale) OVER(PARTITION BY Product_ID ORDER BY month ROWS BETWEEN 2 PRECEDING  AND CURRENT ROW) As moving_avg
FROM x;

-- Q. Write a query to find products with increasing sales over the last 3 months.

WITH x AS (SELECT Product_ID, MONTH(Sale_Date) AS month, SUM(Unit_Price*Quantity_Sold)As total_sale
FROM sales_data
WHERE Sale_Date >= '2023-05-01'
  AND Sale_Date < '2023-08-01'
  GROUP BY Product_ID, MONTH(Sale_Date)),


rn AS (SELECT *,
ROW_NUMBER() OVER(PARTITION BY Product_ID ORDER BY month) As row_num
FROM x)

SELECT * FROM rn 
JOIN rn AS rn2
ON rn.Product_ID = rn2.Product_ID  AND rn2.row_num = 2
JOIN rn AS rn3
ON rn.Product_ID = rn3.Product_ID  AND rn3.row_num = 3
WHERE rn.row_num = 1
AND rn.total_sale < rn2.total_sale AND rn2.total_sale < rn3.total_sale

-- Write a query to get the nth highest salary per department. 




