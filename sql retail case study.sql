
create database Retail;

show databases;

use Retail;

select * from customer;
select * from prod_cat_info;
select * from Transactions;





-- DATA PREPARATION AND UNDERSTANDING

-- 1.	What is the total number of rows in each of the 3 tables in the database?

select count(*) from customer;
select count(*) from prod_cat_info;
select count(*) from transactions;

--  2. What is the total number of transactions that have a return?

select count(*) total_trans from transactions where Qty <0;

--   3. Convert date variables into valid date formats

alter table customer
alter column DOB date;


alter table transactions
alter column tran_date date

-- 4. What is the time range of transaction data available for analysis?
-- show the output in number of days, months and years simultaneously in different columns

SELECT * from Transactions

select DATEDIFF(d,min(tran_date),max(tran_date))  'no_of_days',
DATEDIFF(m,min(tran_date),max(tran_date)) 'no_of_months',
DATEDIFF(y,min(tran_date),max(tran_date))  'no_of_years' from Transactions



--5. what product category does the sub-category "DIY" belong to?

select * from  prod_cat_info


select prod_cat from prod_cat_info
where prod_subcat = 'DIY'


-- data analysis

-- 1. which channel is most frequently used for transaction?


select * from Transactions

select top 1 Store_type from Transactions
group by Store_type order by COUNT(Store_type) desc



-- 2. what is the count of male and female customer in the database?

select * from Customer

select Gender, count(Gender) gender_count from Customer
group by Gender having Gender in ('M','F')


-- 3. from which city do we have maximum no of customers and how many?

select * from Customer

select top 1 city_code, count(city_code) as no_of_customer  from Customer
group by city_code order by count(city_code) desc


-- 4. how many sub_categories are there under the books category?

select * from prod_cat_info

select prod_cat, count(prod_subcat) as no_of_sub_cat 
from prod_cat_info
where prod_cat='Books'
group by prod_cat


-- 5. what is max quantity of products ever ordered?

SELECT * from Transactions

select max(Qty) as max_qnty_of_prd from Transactions



-- 6. what is the net total revenue generated in catogories 
--         electronics and books?

select * from prod_cat_info
select * from Transactions


select prod_cat,sum(convert(numeric,total_amt)) as total_amnt 
from prod_cat_info as t1
right join Transactions as t2 on t1.prod_cat_code=t2.prod_cat_code
group by prod_cat having
prod_cat='ELECTRONICS' or prod_cat='BOOKS'


-- 7. how many customer have >10 transactions with us excluding return?

select * from Transactions

select count(cust_id) as cust_trans from
(select cust_id from Transactions
where Qty > 0
group by cust_id
having count(transaction_id) > 10) a



-- 8. What is the combined revenue earned from the "Electronics" & "Clothing" 
--    categories, from "Flagship stores"?

select * from Transactions
select * from prod_cat_info

select sum(convert(numeric,total_amt)) as total_amt from
prod_cat_info as p1 left join Transactions as t1 on 
p1.prod_cat_code = t1.prod_cat_code
where (prod_cat='Clothing' and Store_type='Flagship store') 
or (prod_cat='Electronics' and Store_type='Flagship store')



-- 9. what is the total revenue generated from "male" customer in "electronics'
-- category ? output should display total revenue by pro sub_cat.

select* from Customer
select * from Transactions
select * from prod_cat_info



select prod_subcat,  sum(convert(numeric,total_amt)) as revenue_from_male_on_electonics from Transactions t1
inner join Customer c on cust_id=c.customer_Id 
inner join prod_cat_info p1 on  t1.prod_cat_code =p1.prod_cat_code 
and t1.prod_subcat_code=p1.prod_sub_cat_code
where Gender='M' and prod_cat='Electronics'
group by prod_subcat


-- 10. what is a percentage of sales and returns by product sub category ;
-- display only top 5 sub categories in terms of sales.




select  top 5 * 
from (select prod_subcat, sum(convert(numeric,total_amt))*100/(select sum(convert(numeric,total_amt)) as sales from  Transactions) as sale_amnt
from prod_cat_info as p
left join Transactions as t1 on p.prod_cat_code=t1.prod_cat_code  where convert(numeric,total_amt)>0
group by prod_subcat) t1 left join (
select prod_subcat,
sum(convert(numeric,total_amt))*100/(select sum(convert(numeric,total_amt)) as sales from  Transactions) as return_amnt
from prod_cat_info as p1
left join Transactions as t1 on p1.prod_cat_code=t1.prod_cat_code  where convert(numeric,total_amt)<0
group by prod_subcat) t2 on t1.prod_subcat=t2.prod_subcat
order by sale_amnt


-- 11. For all customers aged between 25 to 35 years find what is the net total revenue generated by 
-- these consumers in last 30 days of transactions from max transaction date available in the data*/


select customer_Id, datediff(year, DOB, tran_date) as [age], 
(select round(sum(convert(numeric,total_amt)),2)) as total_revenue
from Transactions inner join Customer 
on cust_id = customer_Id
where datediff(year, DOB, tran_date) between 25 and 35
group by customer_Id, DOB, tran_date
having datediff(day, tran_date, (select max(tran_date) from Transactions)) <=30
order by [age]


-- 12. Which product category has seen the max value of returns in the last 3 months of transactions??


select top 1 prod_cat, max(convert(numeric,total_amt)) as rtrn_amnt
from prod_cat_info 
left join Transactions on prod_cat_info.prod_cat_code=Transactions.prod_cat_code
where convert(numeric,total_amt)<0 and (DATEDIFF(month,convert(date,tran_date,105),
(select max(convert(date,tran_date,105)) from Transactions))) = 3
group by prod_cat order by rtrn_amnt



-- 13.  Which store-type sells the maximum products, by value of sales amount and by quantity sold?


select top 1  store_type   from Transactions 
group by store_type
order by (sum(convert(numeric,Total_amt) )/ COUNT(Qty)) desc
    

-- 14. What are the categories for which average revenue is above the overall average 


select prod_cat  from Transactions
join prod_cat_info  on Transactions.prod_cat_code = prod_cat_info.prod_cat_code 
and prod_subcat_code = prod_sub_cat_code
group by prod_cat
having  avg(convert(numeric,total_amt)) > (Select avg(convert(numeric,total_amt)) from Transactions)
               
			   

-- 15. Find the average and total revenue by each sub category for the categories which are among top 5 categories in terms of quantity sold


select prod_cat, prod_subcat,
sum(convert(numeric,Qty)) as quantity,
avg(convert(numeric,total_amt)) as avg_amnt,
sum(convert(numeric,total_amt)) as sales_amnt
from
prod_cat_info left join Transactions on prod_cat_info.prod_cat_code=Transactions.prod_cat_code
group by prod_cat,prod_subcat having prod_cat in (select top 5 prod_cat 
from prod_cat_info left join Transactions on prod_cat_info.prod_cat_code=Transactions.prod_cat_code
group by prod_cat order by sum(convert(numeric,Qty)) desc)







