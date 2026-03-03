--A. Customer Journey

select *
from subscriptions s
left join plans p
on s.plan_id = p.plan_id
order by customer_id,start_date;


--B. Data Analysis Questions

--1. How many customers has Foodie-Fi ever had?

select count(DISTINCT customer_id) as total_customers
from subscriptions;

--2. What is the monthly distribution of trial plan start_date values 
-- for our dataset - use the start of the month as the group by value

with month_tbl as (
	select *, EXTRACT(month from start_date) as month 
	from subscriptions
	where plan_id = 0
)
select month,count(*) as count_of_plans
from month_tbl
group by month
order by month;

--3. What plan start_date values occur after the year 2020 for our 
-- dataset? Show the breakdown by count of events for each plan_name



with cnt as (
	select plan_id,count(*) as no_of_plans
	from subscriptions
	where EXTRACT(year from start_date) > 2020
	group by plan_id
)
select plan_name,no_of_plans
from cnt 
left join plans p
on cnt.plan_id = p.plan_id
order by no_of_plans DESC;

--4. What is the customer count and percentage of customers 
-- who have churned rounded to 1 decimal place?

with plan_cnt as (
	select plan_name,count(*) as no_of_plans
	from subscriptions s
	left join plans p
	on s.plan_id = p.plan_id
	group by plan_name
)
select plan_name,no_of_plans,ROUND(100 * no_of_plans::decimal/total_plans,1) as percentage
from plan_cnt pc
CROSS JOIN (
SELECT COUNT(DISTINCT customer_id) as total_plans
      FROM subscriptions
)
where plan_name = 'churn';

--5. How many customers have churned straight after their initial 
-- free trial - what percentage is this rounded to the nearest whole number?

with sub_rnum as (
	select *, ROW_NUMBER() OVER(
	PARTITION BY customer_id 
	ORDER BY start_date
	) as r_num
	from subscriptions
)
, cnt as (
	select count(DISTINCT customer_id) as count_of_customers
	from sub_rnum
	where(r_num = 2 and plan_id = 4)
)
select count_of_customers, ROUND((100 * count_of_customers::decimal/total_plans)) as percentage_of_trial_to_churn
from cnt 
CROSS JOIN ( 
	SELECT COUNT(DISTINCT customer_id) as total_plans
      FROM subscriptions
)

--6. What is the number and percentage of customer plans after their initial free trial?


with next_pln_tbl as (
	select customer_id,plan_id,
		LEAD(plan_id) OVER(
							PARTITION BY customer_id
							ORDER BY plan_id
						) as next_plan_id
	from subscriptions
)
select next_plan_id, count(*) as next_plan_count,
	ROUND(
		100*count(*)::decimal/(SELECT COUNT(DISTINCT customer_id) as total_plans FROM subscriptions)
		,2) as next_plan_percentage
from next_pln_tbl
where plan_id = 0 and next_plan_id is not null
group by next_plan_id;

--7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?

with next_pln_tbl as (
	select * ,LEAD(plan_id) OVER(PARTITION BY customer_id ORDER BY start_date) as next_plan_id
	from subscriptions
	where start_date <= '2020-12-31'
)
select plan_id,count(*) as plan_count,
	ROUND(
	100*count(*)::decimal/(select count(distinct customer_id) from subscriptions where start_date <= '2020-12-31')
	,2) as plan_percentage
from next_pln_tbl
where next_plan_id is null
group by plan_id;

--8. How many customers have upgraded to an annual plan in 2020?

select count(distinct customer_id) as no_of_customers_upgraded_to_annual_plan
from subscriptions
where EXTRACT(year from start_date) = 2020 and plan_id = 3;

--9. How many days on average does it take for a customer 
-- to an annual plan from the day they join Foodie-Fi?

with days_tbl as (
	select *,(s2.start_date - s1.start_date) as days_to_transfer_to_annual
	from subscriptions s1
	join subscriptions s2
	on s1.customer_id = s2.customer_id
	where s1.plan_id = 0 and s2.plan_id = 3
)
select ROUND(AVG(days_to_transfer_to_annual)) as avg_days_it_took_customer_to_transfer_to_annual_plan
from days_tbl

--10. Can you further breakdown this average value 
--into 30 day periods (i.e. 0-30 days, 31-60 days etc)


with days_tbl as (
	select *,(s2.start_date - s1.start_date) as days_to_transfer_to_annual
	from subscriptions s1
	join subscriptions s2
	on s1.customer_id = s2.customer_id
	where s1.plan_id = 0 and s2.plan_id = 3
),
bins_tbl as (
	select *,
		WIDTH_BUCKET(days_to_transfer_to_annual,0,365,12) as bins
	from days_tbl
),
bin_nm as (
	select *, ((bins - 1)*30 || ' - ' || bins * 30 || ' days') as bucket
	from bins_tbl
)
select bins,bucket,COUNT(*) as count_of_customers
from bin_nm
group by bins,bucket
order by bins;

--11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?

select *
from subscriptions s1
join subscriptions s2
on s1.customer_id = s2.customer_id
where s1.plan_id = 3 and s2.plan_id = 1 and s1.start_date < s2.start_date;

--C. Challenge Payment Question

select * from plans;

WITH plans_clean AS (
    SELECT *
    FROM plans
    WHERE plan_id <> 0   -- exclude trial
),
sub_periods AS (
    SELECT
        s.customer_id,
        s.plan_id,
        p.plan_name,
        p.price,
        s.start_date,
        LEAD(s.start_date) OVER (
            PARTITION BY s.customer_id
            ORDER BY s.start_date
        ) AS next_start_date
    FROM subscriptions s
    JOIN plans p 
        ON s.plan_id = p.plan_id
    WHERE s.plan_id <> 0   -- exclude trial
	ORDER BY customer_id,start_date
),
sub_periods_2020 AS (
    SELECT *,
        COALESCE(
            LEAST(next_start_date - INTERVAL '1 day', DATE '2020-12-31'),
            DATE '2020-12-31'
        ) AS end_date
    FROM sub_periods
    WHERE start_date <= DATE '2020-12-31'
),
monthly_payments AS (
    SELECT
        sp.customer_id,
        sp.plan_id,
        sp.plan_name,
        gs::date AS payment_date,
        sp.price AS amount
    FROM sub_periods_2020 sp
    CROSS JOIN LATERAL generate_series(
        sp.start_date,
        sp.end_date,
        INTERVAL '1 month'
    ) gs
    WHERE sp.plan_id IN (1, 2)  -- basic monthly & pro monthly
),
annual_payments AS (
    SELECT
        sp.customer_id,
        sp.plan_id,
        sp.plan_name,
        sp.start_date AS payment_date,
        sp.price AS amount
    FROM sub_periods_2020 sp
    WHERE sp.plan_id = 3
),
all_payments AS (
    SELECT * FROM monthly_payments
    UNION ALL
    SELECT * FROM annual_payments
),
prorated_upgrades AS (
    SELECT
        ap.customer_id,
        ap.plan_id,
        ap.plan_name,
        ap.payment_date,
        CASE
            WHEN LAG(ap.plan_id) OVER (
                    PARTITION BY ap.customer_id
                    ORDER BY ap.payment_date
                 ) = 1
             AND ap.plan_id = 2
            THEN ap.amount - 9.90
            ELSE ap.amount
        END AS amount
    FROM all_payments ap
),
filtered_payments AS (
    SELECT p.*
    FROM prorated_upgrades p
    LEFT JOIN subscriptions s
        ON p.customer_id = s.customer_id
       AND s.plan_id = 4
       AND s.start_date <= p.payment_date
    WHERE s.customer_id IS NULL
)
SELECT
    customer_id,
    plan_id,
    plan_name,
    payment_date,
    ROUND(amount::numeric, 2) AS amount,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY payment_date
    ) AS payment_order
FROM filtered_payments
WHERE payment_date BETWEEN DATE '2020-01-01' AND DATE '2020-12-31'
ORDER BY customer_id, payment_date;


