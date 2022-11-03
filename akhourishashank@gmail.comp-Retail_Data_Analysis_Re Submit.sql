
----------------------Preparation----------------------------------------------------


create database Retail_Analysis
Use Retail_Analysis

alter table customer
add constraint pk_id primary key (customer_id)

alter table transactions alter column transaction_id varchar(40) not null

alter table transactions alter column prod_cat_code varchar(40) not null

alter table transactions alter column prod_subcat_code varchar(40) not null

alter table prod_cat_info alter column prod_cat_code varchar(40) not null

alter table prod_cat_info alter column prod_sub_cat_code varchar(40) not null



alter table transactions
add constraint fk_custID foreign key (cust_id) references customer (customer_id)

alter table prod_cat_info
add constraint comp_catCode primary key (prod_cat_code, prod_sub_cat_code)

alter table transactions
add constraint fk_category foreign key (prod_cat_code, prod_subcat_code) references prod_cat_info (prod_cat_code, prod_sub_cat_code)

alter table transactions alter column total_amt float
alter table transactions alter column tax float
alter table transactions alter column qty float

-----------------DATA PREPARATION AND UNDERSTANDING------------------------------------------


/*	1.	Table			Rows
		Customer		5647
		Transactions	23053
		Prod_cat_info	23

*/

SELECT * FROM (
SELECT 'customer' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM customer UNION ALL
SELECT 'Transactions' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Transactions UNION ALL
SELECT 'Prod_cat_info' AS TABLE_NAME, COUNT(*) AS NO_OF_RECORDS FROM Prod_cat_info
) TBL



/*	2. Total transactions that have return */

SELECT COUNT (*) [Total Returns] FROM Transactions
where Qty < 0


/*	3. Dates converted into date format during the time of data export */

sp_help 'customer'
sp_help 'transactions'
sp_help 'prod_cat_info'

/*	4. Time range of transactions table */


Select 
	MIN(tran_date) AS Start_tran_Date,
    MAX(tran_date) AS End_tran_Date,
	Datediff(day,Min((CONVERT(date, tran_date, 103))),Max(CONVERT(date, tran_date, 103))) [No._Of_Days],
	Datediff(month,Min((CONVERT(date, tran_date, 103))),Max(CONVERT(date, tran_date, 103))) [No._Of_Months],
	Datediff(year,Min((CONVERT(date, tran_date, 103))),Max(CONVERT(date, tran_date, 103))) [No._Of_Years]
from Transactions


/*	5. Sub category 'DIY' Belons to */

select prod_cat [DIY Belongs to Category] from prod_cat_info
where prod_subcat = 'DIY'




---------------------------DATA ANALYSIS------------------------------------------

--Q1--Begin

select top 1 store_type [Trans_Channel] , count (store_type) [No.Of Transactions] from transactions
group by store_type
order by count (store_type) desc




--Q1--End


--Q2--Begin

select Gender, count (gender) [count] from customer
group by Gender
order by count (gender) desc




--Q2--End


--Q3--Begin


select top 1 city_Code, count (city_code) [No. Of Customers] from Customer
group by city_code
order by count (city_code) desc



--Q3--End


--Q4--Begin


select prod_subcat from prod_cat_info
where prod_cat = 'Books'




--Q4--End


--Q5--Begin

select top 1 t.prod_cat_code, p.prod_cat,count (t.Qty) [Cont]
	from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
		group by t.prod_cat_code,
				 p.prod_cat
		order by Cont desc




--Q5--End


--Q6--Begin



select t.prod_cat_code, p.prod_cat,(sum (t.total_amt) - sum (t.Tax)) [Net_Total_Revenue]
	from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
		where p.prod_cat = 'Electronics' or p.prod_cat = 'Books'
		group by t.prod_cat_code,
				 p.prod_cat




--Q6--End


--Q7--Begin

select cust_id , count (cust_id) [No._Of_Transactions] from Transactions
	where Qty > 0
	group by cust_id
	having count (cust_id) >10 
	select @@ROWCOUNT [Customers having greater than 10 transactions]
	


--Q7--End


--Q8--Begin



	select t.Store_type, sum (t.total_amt) [Total_Revenue]
	from Transactions t inner join prod_cat_info p on t.prod_cat_code=p.prod_cat_code
		where p.prod_cat = 'Electronics' or p.prod_cat = 'Clothing'
		group by t.Store_type
		having t.Store_type = 'Flagship store'





--Q8--End


--Q9--Begin	

select c.Gender, t.prod_subcat_code, p.prod_cat, p.prod_subcat, sum (t.total_amt) [Total Revenue] 
	from Customer c inner join Transactions t on c.customer_Id = t.cust_id
					inner join prod_cat_info p on t.prod_subcat_code = p.prod_sub_cat_code
		where c.Gender = 'M'
		group by c.Gender,
				 t.prod_subcat_code,
				 p.prod_cat,
				 p.prod_subcat
		having p.prod_cat = 'Electronics'




--Q9--End



--Q10--Begin



	SELECT TOP 5 
		PROD_SUBCAT, 
		(SUM(TOTAL_AMT)/(SELECT SUM(TOTAL_AMT) FROM Transactions))*100 AS PERCANTAGE_OF_SALES, 
		(COUNT(CASE WHEN QTY< 0 THEN QTY ELSE NULL END)/SUM(QTY))*100 AS PERCENTAGE_OF_RETURN
	FROM Transactions as T
		INNER JOIN 
			prod_cat_info AS P ON T.prod_cat_code = P.prod_cat_code AND T.prod_subcat_code= P.prod_sub_cat_code
	GROUP BY PROD_SUBCAT
	ORDER BY SUM(TOTAL_AMT) DESC







--Q10--End


--Q11--Begin


SELECT 
	CUST_ID,
	SUM(TOTAL_AMT) AS REVENUE FROM TRANSACTIONS
WHERE CUST_ID IN 
	(SELECT CUSTOMER_ID
	 FROM CUSTOMER
		WHERE DATEDIFF(YEAR,CONVERT(DATE,DOB,103),GETDATE()) BETWEEN 25 AND 35)
		AND CONVERT(DATE,TRAN_DATE,103) BETWEEN DATEADD(DAY,-30,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)) 
		AND (SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)
GROUP BY CUST_ID




--Q11--End



--Q12--Begin



SELECT 
	TOP 1 PROD_CAT, 
	SUM(TOTAL_AMT) FROM TRANSACTIONS T1
		INNER JOIN 
			prod_cat_info T2 ON T1.PROD_CAT_CODE = T2.PROD_CAT_CODE AND T1.PROD_SUBCAT_CODE = T2.PROD_SUB_CAT_CODE
		WHERE TOTAL_AMT < 0 
		AND CONVERT(date, TRAN_DATE, 103) BETWEEN DATEADD(MONTH,-3,(SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)) 
	 	AND (SELECT MAX(CONVERT(DATE,TRAN_DATE,103)) FROM TRANSACTIONS)
GROUP BY PROD_CAT
ORDER BY 2 DESC



--Q12--End



--Q13--Begin



select top 1 Store_type,sum(total_amt) [Sale_Amt], sum (Qty) [Qty_Sold] from Transactions
group by Store_type
order by sum(total_amt) desc, sum (Qty) desc




--Q13--End


--Q14--Begin



SELECT 
	PROD_CAT, 
	AVG(TOTAL_AMT) AS AVERAGE
FROM TRANSACTIONS T
	INNER JOIN PROD_CAT_INFO P ON T.PROD_CAT_CODE=P.PROD_CAT_CODE AND PROD_SUB_CAT_CODE=PROD_SUBCAT_CODE
GROUP BY PROD_CAT
HAVING AVG(TOTAL_AMT)> (SELECT AVG(TOTAL_AMT) FROM TRANSACTIONS) 




--Q14--End



--Q15--Begin


SELECT 
	PROD_CAT, 
	PROD_SUBCAT, 
	AVG(TOTAL_AMT) AS AVERAGE_REV, 
	SUM(TOTAL_AMT) AS REVENUE
FROM TRANSACTIONS T
	INNER JOIN PROD_CAT_INFO P ON T.PROD_CAT_CODE=P.PROD_CAT_CODE
	AND PROD_SUB_CAT_CODE=PROD_SUBCAT_CODE
WHERE PROD_CAT IN
(
SELECT TOP 5 
	PROD_CAT
FROM TRANSACTIONS T
	INNER JOIN PROD_CAT_INFO P ON T.PROD_CAT_CODE=P.PROD_CAT_CODE
	AND PROD_SUB_CAT_CODE = PROD_SUBCAT_CODE
GROUP BY PROD_CAT
ORDER BY SUM(QTY) DESC
)
GROUP BY PROD_CAT, PROD_SUBCAT 

--Q15--End


/*____________________________________Thank You___________________________________________________________*/

