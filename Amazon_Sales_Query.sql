CREATE DATABASE Amazon_Sales
USE Amazon_Sales
SELECT * FROM Product_Sales_Report
SELECT * FROM Shipping_Details
SELECT * FROM Shipping_Detailss

---1]Find orders with detailed shipping information where status is Shipped
SELECT PSR.*, SD.*
FROM Product_Sales_Report PSR
JOIN Shipping_Details SD ON PSR.Order_ID = SD.Order_ID
WHERE PSR.Status='Shipped'

---2]Identify the top 3 categories with the highest average order amounts.
SELECT TOP 3
Category,ROUND(AVG(Amount),0) AS Average_Order_amount
FROM Product_Sales_Report
GROUP BY Category
ORDER BY AVG(Amount) DESC
                   ---OR   
---2]Identify the top 3 categories with the highest average order amounts along with average ordered quantity.
SELECT TOP 3
Category,ROUND(AVG(Amount),0) AS Average_Order_amount, ROUND(AVG(Qty),0) As Average_Qty
FROM Product_Sales_Report
GROUP BY Category
ORDER BY AVG(Amount) DESC

---3] Find the total sales amount for orders that have been Shipped, grouped by the fulfillment method.
SELECT Fulfilment,SUM(Amount) AS Total_Sale_Amount,Status
FROM Product_Sales_Report
Where Status IN ('Shipped','Shipped - Delivered to Buyer')
GROUP BY Fulfilment,Status

---4]FInd the average order amount for each size category, considering only orders with a quantity greater than 1.
SELECT Size, ROUND(AVG(Amount),0) As Avg_Order_amount
FROM Product_Sales_Report
WHERE Qty>1
GROUP by Size

---5] Find Orders Shipped by 'Easy Ship' to Karnataka
SELECT PSR.Order_ID,SD.ship_state,SD.fulfilled_by
FROM Product_Sales_Report PSR JOIN Shipping_Details SD
ON PSR.Order_ID=SD.Order_ID
WHERE SD.ship_state='Karnataka' AND SD.fulfilled_by='Easy Ship'
GROUP BY PSR.Order_ID,SD.ship_state,SD.fulfilled_by
                        --- OR 
---5.1] Find the total number of orders shipped by 'Easy Ship' to according to different states.
SELECT SD.ship_state,COUNT(PSR.Order_ID) AS Total_Orders,SD.fulfilled_by
FROM Product_Sales_Report PSR JOIN Shipping_Details SD
ON PSR.Order_ID=SD.Order_ID
WHERE SD.fulfilled_by='Easy Ship'
GROUP BY SD.ship_state,SD.fulfilled_by
ORDER BY Total_Orders DESC

---6]Find the top 5 categories with the highest total sales amount.
SELECT TOP 5 Category, SUM(Amount) AS TotalSalesAmount
FROM Product_Sales_Report
GROUP BY Category
ORDER BY TotalSalesAmount DESC

---7]find the average order amount for orders fulfilled by Easy Ship
SELECT SD.fulfilled_by,Avg(Amount) AS Avg_Order_Amount
FROM Product_Sales_Report PSR JOIN Shipping_Details SD
ON PSR.Order_ID=SD.Order_ID
WHERE SD.fulfilled_by='Easy Ship'
GROUP BY SD.fulfilled_by
ORDER BY Avg_Order_Amount DESC
             ---OR
---7.1]Using Sub-Query
SELECT AVG(Amount) AS AvgOrderAmountEasyShip
FROM Product_Sales_Report
WHERE Order_ID IN (SELECT Order_ID FROM Shipping_Details WHERE fulfilled_by = 'Easy Ship')

---8]Data Modification:-
---8.1]Update the 'courier_status' column in the 'shipping_details' table to 'Delivered' for orders with a courier status of 'shipped.'
UPDATE Shipping_Details
SET Courier_Status = 'Delivered'
WHERE Courier_Status = 'Shipped'

---9] DELETE And ROLLBACK 
BEGIN TRANSACTION

-- Delete rows
DELETE FROM Shipping_Details
WHERE ship_state='Tamil Nadu'

-- Rollback 
ROLLBACK

---10]Calculate the percentage of cancelled orders.
SELECT
(COUNT(CASE WHEN Status = 'Cancelled' THEN 1 END) * 100.0 / COUNT(*)) AS Cancelled_Orders_Percentage
FROM Product_Sales_Report

---11]Find the top 5 Customers by total amount spent
SELECT TOP 5  MAX(Amount) AS Total_Amount_Spend,PSR.Order_ID, SD.ship_country, SD.ship_state
FROM Product_Sales_Report PSR
JOIN Shipping_Details SD ON PSR.Order_ID = SD.Order_ID
GROUP BY PSR.Order_ID, SD.ship_country, SD.ship_state
ORDER BY Total_Amount_Spend DESC

---12] Calculate month-over-month growth in sales for each category
SELECT Category,DATENAME(month, Date) AS Sales_Month,ROUND(SUM(Amount),0) AS Total_Sales,
LAG(SUM(Amount)) OVER (PARTITION BY Category ORDER BY DATENAME(month, Date)) AS Previous_Month_Sales
FROM Product_Sales_Report
GROUP BY Category, DATENAME(month, Date)
ORDER BY Category,Sales_Month
						---OR
---12.1]Find the month-over-month PERCENTAGE growth in sales for each category.
SELECT PSR.Category, 
DATENAME(MONTH FROM PSR.Date) AS Month,
(SUM(PSR.Amount) - LAG(SUM(PSR.Amount)) OVER (PARTITION BY PSR.Category ORDER BY DATENAME(MONTH FROM PSR.Date))) 
/ LAG(SUM(PSR.Amount)) OVER (PARTITION BY PSR.Category ORDER BY DATENAME(MONTH FROM PSR.Date)) * 100 AS Sales_Growth
FROM Product_Sales_Report PSR
GROUP BY PSR.Category, DATENAME(MONTH FROM PSR.Date)

						---OR
---12.2] USING CTE:-
--- Calculate month-over-month growth in sales for each category
WITH Monthly_Sales AS
  (SELECT Category,DATENAME (month, Date) AS Sales_Month,SUM(Amount) AS Total_Sales
   FROM Product_Sales_Report
   GROUP BY Category, DATENAME(month, Date))

SELECT Category,Sales_Month,Total_Sales,
  LAG(Total_Sales) OVER (PARTITION BY Category ORDER BY Sales_Month) AS Previous_Month_Sales,
  Total_Sales - LAG(Total_Sales) OVER (PARTITION BY Category ORDER BY Sales_Month) AS Sales_Growth
FROM Monthly_Sales
ORDER BY Category, Sales_Month















