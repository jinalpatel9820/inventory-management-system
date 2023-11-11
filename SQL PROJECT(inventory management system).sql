create schema inventory2;

CREATE TABLE IF NOT EXISTS SUPPLIER (
SID CHAR (20), 
SNAME VARCHAR (25),
SADDR VARCHAR (50),
SCITY VARCHAR (30),
SPHONE CHAR (20),
SEMAIL VARCHAR (30)
);

CREATE TABLE IF NOT EXISTS PRODUCT(
PID CHAR(20),
PDESC varchar(25),
PRICE DECIMAL(10,2),
CATEGORY varchar(25),
SID CHAR(20)
);

CREATE TABLE IF NOT EXISTS CUSTOMERS(
CID char(20),
CNAME varchar(25),
CADDR varchar(50),
CCITY varchar(20),
CPHONE char(20),
CEMAIL varchar(30),
CDOB date
);

CREATE TABLE IF NOT EXISTS ORDERS(
OID char(20),
ODATE date,
CID char(10),
PID char(10), 
OQTY decimal(10,2)
);

CREATE TABLE IF NOT EXISTS stock(
PID char(20),
SQTY decimal(10,2),
ROL decimal(10,2),
MOQ decimal(10,2)
);


1. Find the total amount spent by each customer on orders from the CUSTOMERS and ORDERS tables.
SELECT C.CNAME, SUM(P.PRICE * O.OQTY) AS Total_Spending 
FROM CUSTOMERS C 
JOIN ORDERS O ON C.CID = O.CID 
JOIN PRODUCT P ON O.PID = P.PID 
GROUP BY C.CNAME;


2. Retrieve the products and quantities ordered by each customer from the CUSTOMERS and ORDERS tables.
SELECT C.CNAME, P.PDESC, O.OQTY 
FROM CUSTOMERS C 
JOIN ORDERS O ON C.CID = O.CID 
JOIN PRODUCT P ON O.PID = P.PID;


3. Calculate the total revenue generated by each supplier. 
SELECT SNAME, SUM(OQTY * PRICE) AS TOTAL_REVENUE
FROM SUPPLIER
JOIN PRODUCT ON SUPPLIER.SID = PRODUCT.SID
JOIN ORDERS ON PRODUCT.PID = ORDERS.PID
GROUP BY SNAME;

4. Find the customers who have not placed any orders from the CUSTOMERS and ORDERS tables.
SELECT C.CNAME 
FROM CUSTOMERS C 
LEFT JOIN ORDERS O ON C.CID = O.CID 
WHERE O.CID IS NULL;


5. Find the total amount spent by each customer on orders.
SELECT CNAME, 
    (SELECT SUM(PRICE * OQTY) 
     FROM PRODUCT P 
     JOIN ORDERS O ON P.PID = O.PID 
     WHERE O.CID = C.CID) AS Total_Spending 
FROM CUSTOMERS C;


6. Find the customers who have placed orders for products priced over 5000.
SELECT CNAME 
FROM CUSTOMERS 
WHERE CID IN (SELECT CID 
              FROM ORDERS 
              WHERE PID IN (SELECT PID 
                            FROM PRODUCT 
                            WHERE PRICE > 5000));
                            
                            
7. Retrieve the products and their prices for orders placed in 2018.                          
SELECT PDESC, PRICE 
FROM PRODUCT 
WHERE PID IN (SELECT PID 
              FROM ORDERS 
              WHERE YEAR(ODATE) = 2018);
              
              
8. Retrieve the customers who have placed orders for products priced more than the average product price.              
SELECT CNAME 
FROM CUSTOMERS 
WHERE CID IN (SELECT CID 
              FROM ORDERS 
              WHERE PID IN (SELECT PID 
                            FROM PRODUCT 
                            WHERE PRICE > (SELECT AVG(PRICE) 
                                          FROM PRODUCT)));
                                          
                                          
9. Get the total quantities of products with a minimum order quantity greater than 10.                                             
SELECT PID, 
    (SELECT SUM(SQTY) 
     FROM STOCK 
     WHERE PID = S.PID 
     HAVING MIN(MOQ) > 10) AS Total_Quantity 
FROM STOCK S 
GROUP BY PID;


10. Get the products and their corresponding categories.
SELECT PDESC, 
    (SELECT CATEGORY 
     FROM PRODUCT 
     WHERE PID = P.PID) AS CATEGORY 
FROM PRODUCT P; 

                                         
11. Retrieve the products and their prices for the products with quantities greater than 5.
SELECT PDESC, PRICE 
FROM PRODUCT 
WHERE PID IN (SELECT PID 
              FROM STOCK 
              WHERE SQTY > 5);
              
              
12. Get the customers and the total quantity of products they have ordered in the 'HA' category.              
SELECT CNAME, 
    (SELECT SUM(OQTY) 
     FROM ORDERS 
     WHERE CID = C.CID 
     AND PID IN (SELECT PID 
                 FROM PRODUCT 
                 WHERE CATEGORY = 'HA')) AS Total_Quantity 
FROM CUSTOMERS C;


13. Retrieve all customers with names containing 'm' as the third letter.
SELECT * 
FROM CUSTOMERS 
WHERE CNAME LIKE '__m%';


14. Retrieve all suppliers and the number of products they supply, showing only those suppliers who supply more than 2 products.
SELECT SUPPLIER.SID, SNAME, COUNT(PRODUCT.PID) as PRODUCT_COUNT
FROM SUPPLIER
LEFT JOIN PRODUCT ON SUPPLIER.SID = PRODUCT.SID
GROUP BY SUPPLIER.SID, SNAME
HAVING COUNT(PRODUCT.PID) > 2;


15. number of products with a price greater than $100 they supply, showing only those suppliers who supply more than 1 such product.
SELECT SUPPLIER.SID, SNAME, COUNT(PRODUCT.PID) as PRODUCT_COUNT
FROM SUPPLIER
LEFT JOIN PRODUCT ON SUPPLIER.SID = PRODUCT.SID
WHERE PRODUCT.PRICE > 100
GROUP BY SUPPLIER.SID, SNAME
HAVING COUNT(PRODUCT.PID) > 1;


16. showing only those customers who made more than 1 order on that date.
SELECT CUSTOMERS.CID, CNAME, COUNT(ORDERS.OID) as ORDER_COUNT
FROM CUSTOMERS
LEFT JOIN ORDERS ON CUSTOMERS.CID = ORDERS.CID
WHERE ORDERS.ODATE = '2018-02-20'
GROUP BY CUSTOMERS.CID, CNAME
HAVING COUNT(ORDERS.OID) > 1;


17.  Retrieve the details of all products that are currently in stock and their respective quantities.
SELECT PRODUCT.PID, PDESC, SQTY
FROM PRODUCT
LEFT JOIN STOCK ON PRODUCT.PID = STOCK.PID;


18. Retrieve products that have not been ordered.
SELECT PDESC
FROM PRODUCT P
WHERE NOT EXISTS (
    SELECT 1
    FROM ORDERS O
    WHERE O.PID = P.PID
);


19. Retrieve orders placed by customers in the year 2018.
SELECT OID, ODATE
FROM ORDERS O
WHERE EXISTS (
    SELECT 1
    FROM CUSTOMERS C
    WHERE C.CID = O.CID
    AND YEAR(ODATE) = 2018
);


20. List the top 5 most expensive products available in the inventory.
SELECT P.PDESC, P.PRICE
FROM PRODUCT P
ORDER BY P.PRICE DESC
LIMIT 5;


21. Find the products that have never been ordered.
SELECT PDESC
FROM PRODUCT
LEFT JOIN ORDERS ON PRODUCT.PID = ORDERS.PID
WHERE ORDERS.PID IS NULL;

22. Find suppliers who have supplied products with a stock quantity below 10.
SELECT SID, SNAME, COUNT(PID) AS PRODUCT_COUNT
FROM SUPPLIER
JOIN PRODUCT ON SUPPLIER.SID = PRODUCT.SID
JOIN STOCK ON PRODUCT.PID = STOCK.PID
WHERE SQTY < 10
GROUP BY SID, SNAME
HAVING PRODUCT_COUNT > 0
LIMIT 10;