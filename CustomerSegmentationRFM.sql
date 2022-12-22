/**Customer Segmentation Analysis**/
-- Step 1. Filter the dataset
-- Step 2. Exploit the dataset
-- Step 3. summarise the dataset
-- Step 4. Put together the RFM Report
--use AdventureWorks2012

-- Step 1. Filter the dataset

WITH filter_dataset AS 
(
	select 
		CustomerID,
		OrderDate,
		SOD.SalesOrderID,
		TotalDue
	from [Sales].[SalesOrderHeader] as SOH
	left join [Sales].[SalesTerritory] as ST
	on SOH.TerritoryID = ST.TerritoryID
	left join [Sales].[SalesOrderDetail] as SOD
	on SOH.SalesOrderID = SOD.SalesOrderID

	where  CountryRegionCode = 'GB' 
),
-- Step 2. Exploit the dataset
--select  CustomerID,
--		OrderDate,
--		SalesOrderID,
--		--SalesOrderNumber,
--		TotalDue,
--		COUNT(SalesOrderID) over(PARTITION BY CustomerID,SalesOrderID) AS TotalOrder
--from filter_dataset

-- Step 3. summarise the dataset

ordersummary as (
	select CustomerID,
			OrderDate,
			SalesOrderID,
			sum(TotalDue) as TotalSales
	from filter_dataset
	group by CustomerID, OrderDate, SalesOrderID
)
-- Step 4. Put together the RFM Report
select
t1.CustomerID, -- t1.OrderDate, t1.SalesOrderID,
--(select MAX(OrderDate) from ordersummary) as max_orderdate,
--(select MAX(OrderDate) from ordersummary where CustomerID = t1.CustomerID) as max_customer_orderDate,
DATEDIFF(DAY, (select MAX(OrderDate) from ordersummary 
where CustomerID = t1.CustomerID),(select MAX(OrderDate) from ordersummary)) as Recency,
count(t1.SalesOrderID) as Frequency,
SUM(t1.TotalSales) as TotalSales,
NTILE(3) over(order by DATEDIFF(DAY, (select MAX(OrderDate) from ordersummary 
where CustomerID = t1.CustomerID),(select MAX(OrderDate) from ordersummary)) desc) as R,
NTILE(3) over(order by count(t1.SalesOrderID) asc) F,
NTILE(3) over(order by SUM(t1.TotalSales) asc) M
from ordersummary t1
group by t1.CustomerID
order by 1, 3 desc