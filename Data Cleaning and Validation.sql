--VALIDATION AND CLEANING of PRODUCTS TABLE

--Checking for data errors on Description
Select StockCode, Description
from PortfolioProjects..ecommerce_product_raw 
order by Description asc

--Checking for null values
Select StockCode, Description
from PortfolioProjects..ecommerce_product_raw 
where StockCode is null
or Description is null

--Identified error values:
---Adjustment
---adjustment
---add stock
---amazon
---AMAZON
---check
---damaged
---did  a credit  and did not tick ret
---dotcom
---found 
---FOUND
---Found
---had been put aside
---incorrectly credited C550456 see 47
---mailout
---Marked as 23343
---michel oops
---on cargo order
---rcvd be air temp fix for dotcom sit
---Sale error
---test
---wrongly coded 20713

--Filtering out data with error values and putting them in a new temp table

select StockCode, Description, UnitPrice
into #ecommerce_product
from PortfolioProjects..ecommerce_product_raw 
where Description not like '%justment%'
   or Description not like '%add stock%'
   or Description not like '%mazon%'
   or Description not like '%MAZON%'
   or Description <> 'check'
   or Description not like '%damaged%'
   or Description not like '%did  a credit  and did not tick ret%'
   or Description not like '%dotcom%'
   or Description not like '%found%'
   or Description not like '%FOUND%'
   or Description not like '%had been put aside%'
   or Description not like '%ncorrectly%'
   or Description not like '%ailout%'
   or Description not like '%arked as%'
   or Description not like '%michel oops%'
   or Description not like '%on cargo order%'
   or Description not like '%ale error%'
   or Description not like '%test%'
   or Description not like '%rongly coded%'


--Identifying and removing duplicates using row_number()
with rownumcte (StockCode,Description, UnitPrice,rownum) as (
select StockCode, Description, UnitPrice, ROW_NUMBER() over (partition by StockCode order by UnitPrice) as rownum
from PortfolioProjects..ecommerce_product_raw
)
delete from #ecommerce_product
where StockCode in (
					select StockCode
					from rownumcte
					where rownum > 1)

--Insert cleaned data into new clean table
select*
into PortfolioProjects..ecommerce_product_clean
from #ecommerce_product

 -----------------------------------------------------------------------------------------------------------------------------------------
--VALIDATION AND CLEANING of CUSTOMER TABLE

--Check for nulls
select*
from PortfolioProjects..ecommerce_customers_raw
where CustomerID is null
or Country is null

--Remove nulls and create new temp table.
select*
into #ecommerce_customers
from PortfolioProjects..ecommerce_customers_raw
where CustomerID is not null
and Country is not null

--Identify and remove duplicates
with rownumcte (CustomerID, Country, rownum) as (
select*, ROW_NUMBER() over (partition by CustomerID order by CustomerID) as rownum
from #ecommerce_customers
)
delete from #ecommerce_customers

where CustomerID in (select CustomerID
					 from rownumcte
					 where rownum > 1)

--Insert temp table data into new table
select*
into PortfolioProjects..ecommerce_customers_clean
from #ecommerce_customers
 
 -----------------------------------------------------------------------------------------------------------------------------------------
--VALIDATION AND CLEANING of ORDER TABLE

--Identify row with null values, and place in new temp table
select*
into #ecommerce_orders
from PortfolioProjects..ecommerce_orders_raw
where InvoiceNo is null
   or StockCode is null
   or Quantity is null
   or InvoiceDate is null
   or CustomerID is null


--identify and remove duplicates
with rownumcte (InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID, rownum) as (
select*, ROW_NUMBER() over (partition by InvoiceNo, StockCode, Quantity, InvoiceDate, CustomerID order by InvoiceNo) as rownum
from PortfolioProjects..#ecommerce_orders
)
delete from PortfolioProjects..#ecommerce_orders
where InvoiceNo in (select InvoiceNo from rownumcte where rownum > 1)
and   StockCode in (select StockCode from rownumcte where rownum > 1)
and	  Quantity in (select Quantity from rownumcte where rownum > 1)

--Place cleaned data in new table
select*
into PortfolioProjects..ecommerce_orders_clean
from #ecommerce_orders

