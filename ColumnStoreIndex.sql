CREATE TABLE [dbo].[MySalesOrderDetail](
[SalesOrderID] [int] NOT NULL,
[SalesOrderDetailID] [int] NOT NULL,
[CarrierTrackingNumber] [nvarchar](25) NULL,
[OrderQty] [smallint] NOT NULL,
[ProductID] [int] NOT NULL,
[SpecialOfferID] [int] NOT NULL,
[UnitPrice] [money] NOT NULL,
[UnitPriceDiscount] [money] NOT NULL,
[LineTotal] [numeric](38, 6) NOT NULL,
[rowguid] [uniqueidentifier] NOT NULL,
[ModifiedDate] [datetime] NOT NULL
 ) ON [PRIMARY]
 GO


 -- Create clustered index
CREATE CLUSTERED INDEX [CL_MySalesOrderDetail] ON [dbo].[MySalesOrderDetail]
( [SalesOrderDetailID])
GO

-- Create Sample Data Table
 -- WARNING: This Query may run upto 2-10 minutes based on your systems resources
INSERT INTO [dbo].[MySalesOrderDetail]
SELECT S1.*
FROM Sales.SalesOrderDetail S1
 GO 100



 -- PERFORMING TEST

 USE [AdventureWorks2014]
 GO
SET STATISTICS IO ON
GO
-- Select Table with regular Index
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, 
AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM [dbo].[MySalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
 GO

 -- CREATE COLUMN STORE INDEX

 -- Create ColumnStore Index
CREATE NONCLUSTERED COLUMNSTORE INDEX [IX_MySalesOrderDetail_ColumnStore]
ON [MySalesOrderDetail]
(UnitPrice, OrderQty, ProductID)
GO



-- Select Table with Columnstore Index
SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM [dbo].[MySalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
 GO

 
 -- compare
 SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM [dbo].[MySalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
 GO

 SELECT ProductID, SUM(UnitPrice) SumUnitPrice, AVG(UnitPrice) AvgUnitPrice,
SUM(OrderQty) SumOrderQty, AVG(OrderQty) AvgOrderQty
FROM [dbo].[MySalesOrderDetail]
GROUP BY ProductID
ORDER BY ProductID
OPTION (IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX)
 GO

 
 -- compare end

 SELECT OBJECT_SCHEMA_NAME(i.OBJECT_ID) SchemaName,
OBJECT_NAME(i.OBJECT_ID ) TableName,
i.name IndexName,
SUM(s.used_page_count) / 128.0 IndexSizeinMB
FROM sys.indexes AS i
INNER JOIN sys.dm_db_partition_stats AS S
ON i.OBJECT_ID = S.OBJECT_ID AND I.index_id = S.index_id
WHERE  i.type_desc = 'NONCLUSTERED COLUMNSTORE'
GROUP BY i.OBJECT_ID, i.name




 -- CLEAN UP
 DROP INDEX [IX_MySalesOrderDetail_ColumnStore] ON [dbo].[MySalesOrderDetail]
 GO
TRUNCATE TABLE dbo.MySalesOrderDetail
 GO
DROP TABLE dbo.MySalesOrderDetail
 GO