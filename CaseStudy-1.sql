/* Providing solution to case study #1 available on https://8weeksqlchallenge.com/case-study-1/ */


--1.  What is the total amount each customer spent at the restaurant?
--2.  How many days has each customer visited the restaurant?
--3.  What was the first item from the menu purchased by each customer?
--4.  What is the most purchased item on the menu and how many times was it purchased by all customers?
--5.  Which item was the most popular for each customer?
--6.  Which item was purchased first by the customer after they became a member?
--7.  Which item was purchased just before the customer became a member?
--8.  What is the total items and amount spent for each member before they became a member?
--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?


SELECT * FROM dbo.members;
SELECT * FROM dbo.menu;
SELECT * FROM dbo.sales;

--1.  What is the total amount each customer spent at the restaurant?

SELECT   S.customer_id, SUM(M.price) as TotalAmount
FROM	 dbo.sales as S INNER JOIN dbo.menu as M ON S.product_id = M.product_id
GROUP BY S.customer_id;

--2.  How many days has each customer visited the restaurant?

SELECT   S.customer_id, COUNT(DISTINCT order_date) as NoOfVisit  
FROM	 dbo.sales AS S
GROUP BY S.customer_id;

--3.  What was the first item from the menu purchased by each customer?

;WITH CTE_FirstItem_List AS
(
SELECT   S.customer_id, M.product_name, S.order_date, DENSE_RANK() OVER(PARTITION BY S.customer_id ORDER BY  order_date) as RowNum
FROM     dbo.sales as S INNER JOIN dbo.menu as M ON S.product_id = M.product_id
)
SELECT  customer_id, product_name, order_date 
FROM	CTE_FirstItem_List 
WHERE	RowNum = 1;

--4.  What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT    TOP 1 M.product_name, COUNT(S.product_id) as Cnt
FROM      dbo.sales as S INNER JOIN dbo.Menu as M ON S.product_id = M.product_id
GROUP BY  M.product_name
ORDER BY  Cnt DESC;

--5.  Which item was the most popular for each customer?

WITH CTE_PopularItem_List_1 AS 
(
SELECT    S.customer_id, M.product_name, COUNT(S.product_id) as Cnt
FROM      dbo.sales as S INNER JOIN dbo.Menu as M ON S.product_id = M.product_id
GROUP BY  S.customer_id, M.product_name
)
   , CTE_PopularItem_List_2 AS 
(
SELECT  *, DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY cnt) as RowNum
FROM    CTE_PopularItem_List_1
)
SELECT Customer_id, product_name FROM CTE_PopularItem_List_2 WHERE RowNum = 1;


--6.  Which item was purchased first by the customer after they became a member?

;WITH CTE_CustomerMinOrderInfo
AS
(
SELECT S.customer_id, MIN(Order_Date) as MinOrderDate
FROM  dbo.members as M INNER JOIN dbo.sales as S ON M.customer_id = S.customer_id 					   
WHERE S.order_date >= M.join_date
GROUP BY S.customer_id
)

SELECT C.customer_id, order_date, ME.product_name 
FROM   CTE_CustomerMinOrderInfo AS C INNER JOIN dbo.sales as S ON S.order_date = C.MinOrderDate AND S.customer_id = C.customer_id
									 INNER JOIN dbo.menu as ME ON ME.product_id = S.product_id;											

--7.  Which item was purchased just before the customer became a member?

;WITH CTE_CustomerMinOrderInfo
AS
(
SELECT S.customer_id, MIN(Order_Date) as MinOrderDate
FROM  dbo.members as M INNER JOIN dbo.sales as S ON M.customer_id = S.customer_id 					   
WHERE S.order_date < M.join_date
GROUP BY S.customer_id
)

SELECT C.customer_id, order_date, ME.product_name 
FROM   CTE_CustomerMinOrderInfo AS C INNER JOIN dbo.sales as S ON S.order_date = C.MinOrderDate AND S.customer_id = C.customer_id
									 INNER JOIN dbo.menu as ME ON ME.product_id = S.product_id;		


--8.  What is the total items and amount spent for each member before they became a member?

;WITH CTE_CustomerMinOrderInfo
AS
(
SELECT S.customer_id, MIN(Order_Date) as MinOrderDate
FROM  dbo.members as M LEFT JOIN dbo.sales as S ON M.customer_id = S.customer_id 					   
WHERE S.order_date < M.join_date
GROUP BY S.customer_id
)

SELECT C.customer_id, COUNT(ME.product_name) as TotalItem, SUM(ME.price) TotalAmount
FROM   CTE_CustomerMinOrderInfo AS C LEFT JOIN dbo.sales as S ON S.order_date = C.MinOrderDate AND S.customer_id = C.customer_id
									 LEFT JOIN dbo.menu as ME ON ME.product_id = S.product_id
GROUP BY C.customer_id

--9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

SELECT S.customer_id, SUM(CASE WHEN Product_Name = 'Sushi' THEN Price * 20 ELSE Price * 10 END) as NumberofPoints
FROM dbo.sales as S INNER JOIN dbo.menu as M ON S.product_id = M.product_id
GROUP BY S.customer_id

--10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

SELECT M.customer_id, SUM(CASE WHEN DATEDIFF(DAY, join_date, order_date) BETWEEN 1 AND 7 THEN PRICE * 20 ELSE 0 END) as TotalPoints  FROM dbo.members as M INNER JOIN dbo.sales as S ON M.customer_id = S.customer_id
							  INNER JOIN dbo.menu as ME ON ME.product_id = S.product_id
GROUP BY M.customer_id

---SELECT * FROM dbo.members ;
---SELECT * FROM dbo.menu;
---SELECT * FROM dbo.sales;