--*************************************************************************--
-- Title: Assignment06
-- Author: CClark
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2017-05-20,CClark,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_CClark')
	 Begin 
	  Alter Database [Assignment06DB_CClark] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_CClark;
	 End
	Create Database Assignment06DB_CClark;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_CClark;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go
Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
print 
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--QUESTION #1 DONE

/**
SELECT * FROM CATEGORIES
GO
**/

GO
CREATE VIEW VCATEGORIES WITH SCHEMABINDING
AS
SELECT
CATEGORYID,
CATEGORYNAME
FROM
DBO.CATEGORIES
GO

/**
SELECT * FROM EMPLOYEES
GO
**/

CREATE VIEW VEMPLOYEES WITH SCHEMABINDING
AS
SELECT
EMPLOYEEID,
EMPLOYEEFIRSTNAME,
EMPLOYEELASTNAME,
MANAGERID
FROM
DBO.EMPLOYEES
GO

/**
SELECT * FROM INVENTORIES
GO
**/


CREATE VIEW VINVENTORIES WITH SCHEMABINDING
AS
SELECT
INVENTORYID,
INVENTORYDATE,
EMPLOYEEID,
PRODUCTID,
COUNT
FROM
DBO.INVENTORIES
GO

/**
SELECT * FROM PRODUCTS
GO
**/

CREATE VIEW VPRODUCTS WITH SCHEMABINDING
AS
SELECT
PRODUCTID,
PRODUCTNAME,
CATEGORYID,
UNITPRICE
FROM
DBO.PRODUCTS
GO

SELECT * FROM VCATEGORIES
SELECT * FROM VEMPLOYEES
SELECT * FROM VINVENTORIES
SELECT * FROM VPRODUCTS
GO




-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?


USE ASSIGNMENT06DB_CCLARK
DENY SELECT ON CATEGORIES TO PUBLIC;
GRANT SELECT ON VCATEGORIES TO PUBLIC;
GO

USE ASSIGNMENT06DB_CCLARK
DENY SELECT ON EMPLOYEES TO PUBLIC;
GRANT SELECT ON VEMPLOYEES TO PUBLIC;
GO

USE ASSIGNMENT06DB_CCLARK
DENY SELECT ON INVENTORIES TO PUBLIC;
GRANT SELECT ON VINVENTORIES TO PUBLIC;
GO

USE ASSIGNMENT06DB_CCLARK
DENY SELECT ON PRODUCTS TO PUBLIC;
GRANT SELECT ON VPRODUCTS TO PUBLIC;
GO


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

/** QUESTION #3 DONE

SELECT * FROM VCATEGORIES
SELECT * FROM VPRODUCTS
GO

SELECT 
CATEGORYNAME,
PRODUCTNAME,
UNITPRICE
FROM 
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
GO

SELECT 
CATEGORYNAME,
PRODUCTNAME,
UNITPRICE
FROM 
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
ORDER BY CATEGORYNAME, PRODUCTNAME
GO

CREATE VIEW vProductsByCategories
AS 
SELECT TOP 10000000
CATEGORYNAME,
PRODUCTNAME,
UNITPRICE
FROM 
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
ORDER BY CATEGORYNAME, PRODUCTNAME
GO

--**/


CREATE VIEW vProductsByCategories
AS 
SELECT TOP 10000000
CATEGORYNAME,
PRODUCTNAME,
UNITPRICE
FROM 
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
ORDER BY CATEGORYNAME, PRODUCTNAME
GO

SELECT * FROM vProductsByCategories

-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!


/**   QUESTION #4 DONE

SELECT * FROM VPRODUCTS
SELECT * FROM VINVENTORIES
GO

SELECT
PRODUCTNAME
FROM
VPRODUCTS
GO

SELECT
COUNT,
INVENTORYDATE
FROM
VInventories
GO

SELECT
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
ORDER BY PRODUCTNAME, INVENTORYDATE, COUNT
GO
--**/

GO
CREATE VIEW vInventoriesByProductsByDates
AS
SELECT TOP 10000000
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
ORDER BY PRODUCTNAME, INVENTORYDATE, COUNT
GO


SELECT * FROM vInventoriesByProductsByDates


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is are the rows selected from the view:

-- InventoryDate	EmployeeName
-- 2017-01-01	    Steven Buchanan
-- 2017-02-01	    Robert King
-- 2017-03-01	    Anne Dodsworth

/** QUESTION 5 DONE

SELECT * FROM VINVENTORIES
SELECT * FROM VEMPLOYEES
GO

SELECT
INVENTORYDATE
FROM
VINVENTORIES
GO

SELECT
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VEMPLOYEES
GO

SELECT
INVENTORYDATE,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VINVENTORIES  AS I JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
GO

SELECT
INVENTORYDATE,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VINVENTORIES  AS I JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
GROUP BY INVENTORYDATE, EMPLOYEEFIRSTNAME +  ' ' + EMPLOYEELASTNAME;
GO

**/

GO
CREATE VIEW vInventoriesByEmployeesByDates
AS
SELECT TOP 100000000
INVENTORYDATE,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VINVENTORIES  AS I JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
GROUP BY INVENTORYDATE, EMPLOYEEFIRSTNAME +  ' ' + EMPLOYEELASTNAME;
GO

SELECT * FROM vInventoriesByEmployeesByDates


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

/**  QUESTION #6 IS DONE 

SELECT * FROM VCATEGORIES
SELECT * FROM VPRODUCTS
SELECT * FROM VINVENTORIES

SELECT
CATEGORYNAME 
FROM
VCATEGORIES
GO

SELECT 
PRODUCTNAME
FROM
VPRODUCTS
GO

SELECT
INVENTORYDATE,
COUNT
FROM
VINVENTORIES
GO

SELECT
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
ORDER BY CATEGORYNAME, PRODUCTNAME, INVENTORYDATE, COUNT
GO
**/

GO
CREATE VIEW vInventoriesByProductsByCategories
AS
SELECT TOP 100000000
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
ORDER BY CATEGORYNAME, PRODUCTNAME, INVENTORYDATE, COUNT
GO

SELECT * FROM vInventoriesByProductsByCategories


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

/** QUESTION #7 DONE

SELECT * FROM VCATEGORIES
SELECT * FROM VPRODUCTS
SELECT * FROM VINVENTORIES
SELECT * FROM VEMPLOYEES
GO

SELECT
CATEGORYNAME
FROM
VCATEGORIES
GO

SELECT 
PRODUCTNAME
FROM
VPRODUCTS
GO

SELECT
INVENTORYDATE,
COUNT
FROM
VINVENTORIES
GO

SELECT
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VEMPLOYEES
GO

SELECT
CATEGORYNAME,
PRODUCTNAME
FROM
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
JOIN
VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
JOIN
VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON E.EMPLOYEEID = I.EMPLOYEEID
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
JOIN
VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON E.EMPLOYEEID = I.EMPLOYEEID
ORDER BY INVENTORYDATE, CATEGORYNAME, PRODUCTNAME, [EMPLOYEE NAME]
GO
**/

GO
CREATE VIEW vInventoriesByProductsByEmployees
AS
SELECT TOP 100000000
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VCATEGORIES AS C JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
JOIN
VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON E.EMPLOYEEID = I.EMPLOYEEID
ORDER BY INVENTORYDATE, CATEGORYNAME, PRODUCTNAME, [EMPLOYEE NAME]
GO

SELECT * FROM vInventoriesByProductsByEmployees


-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

/** QUESTION #8 DONE


SELECT * FROM VCATEGORIES
SELECT * FROM VPRODUCTS
SELECT * FROM VINVENTORIES
SELECT * FROM VEMPLOYEES
GO

SELECT
CATEGORYNAME
FROM
VCATEGORIES
GO

SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG'
GO

SELECT 
INVENTORYDATE,
COUNT
FROM
VINVENTORIES
GO

SELECT
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VEMPLOYEES
GO

SELECT
CATEGORYNAME,
PRODUCTNAME
FROM
VPRODUCTS AS P JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
WHERE PRODUCTNAME IN (SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG')
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT
FROM
VPRODUCTS AS P JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
WHERE PRODUCTNAME IN (SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG')
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VPRODUCTS AS P JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
WHERE PRODUCTNAME IN (SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG')
GO

SELECT
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VPRODUCTS AS P JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
WHERE PRODUCTNAME IN (SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG')
ORDER BY INVENTORYDATE
GO
**/
GO
CREATE VIEW vInventoriesForChaiAndChangByEmployees
AS
SELECT TOP 100000000
CATEGORYNAME,
PRODUCTNAME,
INVENTORYDATE,
COUNT,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE NAME]
FROM
VPRODUCTS AS P JOIN VCATEGORIES AS C
ON C.CATEGORYID = P.CATEGORYID
JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
JOIN VEMPLOYEES AS E
ON I.EMPLOYEEID = E.EMPLOYEEID
WHERE PRODUCTNAME IN (SELECT
PRODUCTNAME
FROM
VPRODUCTS
WHERE PRODUCTNAME = 'CHAI' OR PRODUCTNAME = 'CHANG')
ORDER BY INVENTORYDATE
GO

SELECT * FROM vInventoriesForChaiAndChangByEmployees



-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

/** QUESTION #9 IS DONE


SELECT * FROM VEMPLOYEES

SELECT
EMPLOYEEID,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [MANAGER]
FROM
VEMPLOYEES AS MRG
GO

SELECT
MANAGERID,
EMPLOYEEFIRSTNAME + ' ' + EMPLOYEELASTNAME AS [EMPLOYEE] 
FROM
VEMPLOYEES AS EMP
GO

SELECT
MRG.EMPLOYEEFIRSTNAME + ' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME + ' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VEMPLOYEES AS EMP JOIN VEMPLOYEES AS MRG
ON EMP.MANAGERID = MRG.EMPLOYEEID
GO

SELECT
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VEMPLOYEES AS EMP JOIN VEMPLOYEES AS MRG
ON 
EMP.MANAGERID = MRG.EMPLOYEEID
ORDER BY [MANAGER], [EMPLOYEE]
GO
**/

GO
CREATE VIEW vEmployeesByManager
AS
SELECT TOP 100000000
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VEMPLOYEES AS EMP JOIN VEMPLOYEES AS MRG
ON 
EMP.MANAGERID = MRG.EMPLOYEEID
ORDER BY [MANAGER], [EMPLOYEE]
GO

SELECT * FROM vEmployeesByManager



-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.
/** QUESTION #10 DONE


SELECT * FROM VCATEGORIES
SELECT * FROM VEMPLOYEES
SELECT * FROM VINVENTORIES
SELECT * FROM VPRODUCTS


SELECT
CATEGORYID,
CATEGORYNAME
FROM 
VCATEGORIES
GO

SELECT
PRODUCTID,
PRODUCTNAME,
UNITPRICE
FROM
VPRODUCTS
GO

SELECT 
INVENTORYID,
INVENTORYDATE,
COUNT
FROM
VINVENTORIES
GO

SELECT
EMPLOYEEID,
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VEMPLOYEES AS EMP JOIN VEMPLOYEES AS MRG
ON 
EMP.MANAGERID = MRG.EMPLOYEEID
GO

SELECT
C.CATEGORYID,
C.CATEGORYNAME,
P.PRODUCTID,
P.PRODUCTNAME,
P.UNITPRICE
FROM
VCATEGORIES AS C INNER JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
GO

SELECT
C.CATEGORYID,
C.CATEGORYNAME,
P.PRODUCTID,
P.PRODUCTNAME,
P.UNITPRICE,
I.INVENTORYID,
I.INVENTORYDATE,
I.COUNT
FROM
VCATEGORIES AS C INNER JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
INNER JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
GO

SELECT
C.CATEGORYID,
C.CATEGORYNAME,
P.PRODUCTID,
P.PRODUCTNAME,
P.UNITPRICE,
I.INVENTORYID,
I.INVENTORYDATE,
I.COUNT,
EMP.EMPLOYEEID,
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VCATEGORIES AS C INNER JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
INNER JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
INNER JOIN VEMPLOYEES AS MRG
ON I.EMPLOYEEID = MRG.EMPLOYEEID
INNER JOIN VEMPLOYEES AS EMP
ON MRG.MANAGERID = EMP.EMPLOYEEID
GO

SELECT
C.CATEGORYID,
C.CATEGORYNAME,
P.PRODUCTID,
P.PRODUCTNAME,
P.UNITPRICE,
I.INVENTORYID,
I.INVENTORYDATE,
I.COUNT,
EMP.EMPLOYEEID,
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VCATEGORIES AS C INNER JOIN VPRODUCTS AS P
ON C.CATEGORYID = P.CATEGORYID
INNER JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
INNER JOIN VEMPLOYEES AS MRG
ON I.EMPLOYEEID = MRG.EMPLOYEEID
INNER JOIN VEMPLOYEES AS EMP
ON MRG.MANAGERID = EMP.EMPLOYEEID
ORDER BY C.CATEGORYID, P.PRODUCTID, I.INVENTORYID, EMP.EMPLOYEEID
GO

**/

GO
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 100000000
C.CATEGORYID,
C.CATEGORYNAME,
P.PRODUCTID,
P.PRODUCTNAME,
P.UNITPRICE,
I.INVENTORYID,
I.INVENTORYDATE,
I.COUNT,
EMP.EMPLOYEEID,
MRG.EMPLOYEEFIRSTNAME +' ' + MRG.EMPLOYEELASTNAME AS [MANAGER],
EMP.EMPLOYEEFIRSTNAME +' ' + EMP.EMPLOYEELASTNAME AS [EMPLOYEE]
FROM
VCATEGORIES AS C INNER JOIN VPRODUCTS AS P
ON P.CATEGORYID = C.CATEGORYID
INNER JOIN VINVENTORIES AS I
ON P.PRODUCTID = I.PRODUCTID
INNER JOIN VEMPLOYEES AS MRG
ON I.EMPLOYEEID = MRG.EMPLOYEEID
INNER JOIN VEMPLOYEES AS EMP
ON MRG.MANAGERID = EMP.EMPLOYEEID
ORDER BY C.CATEGORYID, P.PRODUCTID, I.INVENTORYID, EMP.EMPLOYEEID
GO


SELECT * FROM vInventoriesByProductsByCategoriesByEmployees



-- Test your Views (NOTE: You must change the your view names to match what I have below!)
Print 'Note: You will get an error until the views are created!'
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]

/***************************************************************************************/