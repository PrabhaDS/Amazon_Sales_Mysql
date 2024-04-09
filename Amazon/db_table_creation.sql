create database if not exists amazonsales;

create table  if not exists sales(
	invoice_id varchar(30) not null primary key,
    branch varchar(5) not null,
    city varchar(30) not null,
    customer_type varchar(30) not null,
    gender varchar(20) not null,
    product_line varchar(200) not null,
    unit_price Decimal(10,2) not null,
    quantity int not null,
    vat float(6,4) not null,
    total decimal(10.2) not null,
    date datetime not null,
    time time not null,
    payment_method varchar(15) not null,
    cogs decimal(10,2) not null,
    gross_margin_percentage float(11,9) not null,
    gross_income decimal(12,4) not null,
    rating float(2,1)
    
);
----- ----------- --Feature Engineering-- -------------------------------------
----- ------------- timeofday---------
select 
	time,
	(case
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        else "Evening"
	end) as timeofday from sales;
    alter table sales add column timeofday varchar(20);
    update sales
    set timeofday = (case
		when time between '00:00:00' and '12:00:00' then "Morning"
        when time between '12:01:00' and '16:00:00' then "Afternoon"
        else "Evening"
	end);
------- -------------- dayname---------
select date,
dayname(date) as dayname
from sales;
alter table sales add column dayname varchar(10);
update sales
set dayname = dayname(date);

------- -------------- monthname---------

select date,
	monthname(date) as monthname from sales;
alter table sales add column monthname varchar(10);
update sales set monthname = monthname(date);



-------------- Genric------------------------ --
----- What is the count of distinct cities in the dataset?
select distinct city from sales;
----- For each branch, what is the corresponding city?
select distinct city,branch from sales;
----------- What is the count of distinct product lines in the dataset?
select distinct count(product_line) from sales;
------ -- Which payment method occurs most frequently?
select payment_method, count(payment_method) as most_use from sales group by payment_method order by most_use desc ;
------ -- Which product line has the highest sales?
select product_line, count(product_line) as pl from sales group by product_line order by pl desc;
------- ----- How much revenue is generated each month?
select sum(gross_income) ,monthname from sales group by monthname;
----- -------In which month did the cost of goods sold reach its peak?
select sum(cogs) as ts ,monthname from sales group by monthname order by ts desc limit 1;
------ ----- Which product line generated the highest revenue?
select product_line,sum(gross_income) as hr from sales group by product_line order by hr desc ;
------ -- In which city was the highest revenue recorded?
select city, sum(gross_income) as hr from sales group by city order by hr desc;
--- -- Which product line incurred the highest Value Added Tax?
select product_line,sum(vat) as hv from sales group by product_line order by hv desc;
----- For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select product_line,avg(gross_income) as av,sum(gross_income) as gs,(
 case 
when gross_income>av then "Good"
else "Bad"
end
) as prod from sales group by product_line;

--- -- Identify the branch that exceeded the average number of products sold.
select branch,sum(quantity) as qty from sales group by branch having sum(quantity)>(select avg(quantity) from sales);
select avg(quantity) from sales;	
--- -- Which product line is most frequently associated with each gender?
select gender,product_line,count(gender) from sales group by gender,product_line;
--------- -----      ----

SELECT gender, product_line, COUNT(gender) AS frequency
FROM sales
GROUP BY gender, product_line
HAVING COUNT(gender) = (
    SELECT MAX(count_gender)
    FROM (
        SELECT gender, product_line, COUNT(gender) AS count_gender
        FROM sales
        GROUP BY gender, product_line
    ) AS subquery
    WHERE subquery.gender = sales.gender
)


-------- ---------- Count the sales occurrences for each time of day on every weekday.-----

select timeofday,dayname,count(dayname) ,count(*) as total_sale from sales group by dayname,timeofday order by total_sale desc;
-------- 2 query--------------------------
SELECT timeofday,
       DAYNAME(date) AS day_of_week,
       COUNT(*) AS total_sales
FROM sales
WHERE DAYOFWEEK(date) BETWEEN 2 AND 6  -- Filter out weekends (Monday to Friday)
GROUP BY DAYNAME(date), timeofday
ORDER BY total_sales DESC;

----------- -- Identify the customer type contributing the highest revenue.

select customer_type,sum(total) as high_rev from sales group by customer_type order by high_rev desc;

------ --- -------- Determine the city with the highest VAT percentage.
SELECT city, 
       SUM(vat) AS total_vat,
       (SUM(vat) / SUM(total) * 100) AS vat_percentage
FROM sales
GROUP BY city
ORDER BY vat_percentage DESC
LIMIT 1;


-------- ------Identify the customer type with the highest VAT payments.

select customer_type,sum(vat) as cus_vat from sales group by customer_type order by cus_vat desc ;

----- ------What is the count of distinct customer types in the dataset?
select count(distinct customer_type) as distinct_Customer from sales;

------ ----- ---What is the count of distinct payment methods in the dataset?
----- ------What is the count of distinct customer types in the dataset?
select count(distinct payment_method) as distinct_payment from sales;

----- ------Which customer type occurs most frequently?
SELECT customer_type, COUNT(*) AS occurrence_count
FROM sales
GROUP BY customer_type
ORDER BY occurrence_count DESC
LIMIT 1;

------- -- Identify the customer type with the highest purchase frequency.

SELECT customer_type, 
       COUNT(*) AS purchase_frequency
FROM sales
GROUP BY customer_type
ORDER BY purchase_frequency DESC
LIMIT 1;

----- Determine the predominant gender among customers.
Select gender,
       COUNT(*) AS gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC
LIMIT 1;
----- --Examine the distribution of genders within each branch
select branch, count(gender) as gen from sales group by branch,gender;

----- 2 type query--------
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM sales
WHERE branch = "C" 
GROUP BY gender
ORDER BY gender_cnt DESC;

------ -- Identify the time of day when customers provide the most ratings.
select timeofday,count(*) as most_rating from sales group by timeofday order by most_rating desc;

----- --Identify the day of the week with the highest average ratings.
select dayname,avg(rating) as most_rating from sales group by dayname order by most_rating desc;

---- -- Determine the day of the week with the highest average ratings for each branch.
select dayname,branch,avg(rating) as most_rating from sales group by branch,dayname order by most_rating desc;

------ -- Determine the time of day with the highest customer ratings for each branch.
select timeofday,branch,count(*) as most_rating from sales group by timeofday,branch order by most_rating desc;