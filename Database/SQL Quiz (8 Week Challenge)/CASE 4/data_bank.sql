--1. How many unique nodes are there on the Data Bank system?
 
select count(distinct node_id) as unique_nodes
from customer_nodes;
 
--2. What is the number of nodes per region?
 
select r.region_id,region_name,count(node_id) as node_count
from regions r
left join customer_nodes cn
on r.region_id = cn.region_id
group by r.region_id,region_name;
 
--3. How many customers are allocated to each region?
 
select r.region_id,region_name,count(customer_id) as customer_count
from regions r
left join customer_nodes cn
on r.region_id = cn.region_id
group by r.region_id,region_name;
 
--4. How many days on average are customers reallocated to a different node?
 
with day_tbl as (
	select *,(end_date - start_date) as days 
	from customer_nodes
	where end_date <> '9999-12-31'
	order by customer_id
)
,days as (
	select customer_id,node_id,SUM(days) as days_summed
	from day_tbl dt
	group by customer_id,node_id
)
select ROUND(AVG(days_summed)) as average_days_before_node_gets_rellocated
from days;
 
--5. What is the median, 80th and 95th percentile for this same 
-- reallocation days metric for each region?
with day_tbl as (
	select *,(end_date - start_date) as days 
	from customer_nodes
	where end_date <> '9999-12-31'
	order by customer_id
)
,region_tbl as (
	select customer_id,region_id,node_id,SUM(days) as days_summed
	from day_tbl dt
	group by customer_id,region_id,node_id
)
select region_id
	,ROUND(percentile_cont(0.5) WITHIN GROUP (ORDER BY days_summed)) as median
	,ROUND(percentile_cont(0.8) WITHIN GROUP (ORDER BY days_summed)) as p80
	,ROUND(percentile_cont(0.95) WITHIN GROUP (ORDER BY days_summed)) as p95
from region_tbl
group by region_id;
 
--B. Customer Transactions
 
--1. What is the unique count and total amount for each transaction type?
 
select txn_type,count(distinct customer_id) as unique_count_of_transaction_type,sum(txn_amount) as amount_sum
from customer_transactions
group by txn_type
 
--2. What is the average total historical deposit counts and amounts for all customers?
with temp as (
	select customer_id,count(*) as cnt_dep,AVG(txn_amount) as sum_amt
	from customer_transactions
	where txn_type = 'deposit'
	group by customer_id
)
select ROUND(AVG(cnt_dep)) as avg_dep_counts,ROUND(AVG(sum_amt)) as avg_dep_amount
from temp;
 
--3. For each month - how many Data Bank customers make more than 1 deposit 
-- and either 1 purchase or 1 withdrawal in a single month?
 
with month_tbl as (
	select *,EXTRACT(month from txn_date) as txn_month
	from customer_transactions
)
,cnt as (
	select txn_month,customer_id,txn_type,count(*) as cnt_txn_type
	from month_tbl
	group by txn_month,customer_id,txn_type
	order by txn_month,customer_id
)
,pivotted_tbl as (
	select txn_month,customer_id,  
		SUM( CASE when txn_type = 'deposit' then cnt_txn_type else 0 END) as deposit,
		SUM( CASE when txn_type = 'purchase' then cnt_txn_type else 0 END) as purchase,
		SUM( CASE when txn_type = 'withdrawal' then cnt_txn_type else 0 END) as withdrawal
	from cnt
	group by txn_month,customer_id
)
select txn_month,count(*) as customer_cnt
from pivotted_tbl
where deposit > 1 and (purchase >= 1 or withdrawal >= 1)
group by txn_month


--4. What is the closing balance for each customer at the end of the month?

with month_tbl as (
	select *,EXTRACT(month from txn_date) as txn_month
	from customer_transactions
)
,amount_tbl as (
	select txn_month,customer_id,txn_type,sum(txn_amount) as sum_txn_amount
	from month_tbl
	group by txn_month,customer_id,txn_type
	order by txn_month,customer_id
)
,pivot_tbl as (
	select txn_month,customer_id,
		SUM(CASE when txn_type = 'deposit' then sum_txn_amount else 0 END) as deposit,
		SUM(CASE when txn_type = 'purchase' then sum_txn_amount else 0 END) as purchase,
		SUM(CASE when txn_type = 'withdrawal' then sum_txn_amount else 0 END) as withdrawal
	from amount_tbl
	group by txn_month,customer_id
	order by customer_id,txn_month
)
,m_bal as (
	select *,(deposit - purchase - withdrawal) as monthly_bal
	from pivot_tbl
)
select *,SUM(monthly_bal) OVER(PARTITION BY customer_id ORDER BY txn_month RANGE between unbounded preceding and current row) as net_balance
from m_bal;

--5. What is the percentage of customers who increase their closing balance by more than 5%?
with month_tbl as (
	select *,EXTRACT(month from txn_date) as txn_month
	from customer_transactions
)
,amount_tbl as (
	select txn_month,customer_id,txn_type,sum(txn_amount) as sum_txn_amount
	from month_tbl
	group by txn_month,customer_id,txn_type
	order by txn_month,customer_id
)
,pivot_tbl as (
	select txn_month,customer_id,
		SUM(CASE when txn_type = 'deposit' then sum_txn_amount else 0 END) as deposit,
		SUM(CASE when txn_type = 'purchase' then sum_txn_amount else 0 END) as purchase,
		SUM(CASE when txn_type = 'withdrawal' then sum_txn_amount else 0 END) as withdrawal
	from amount_tbl
	group by txn_month,customer_id
	order by customer_id,txn_month
)
,m_bal as (
	select *,(deposit - purchase - withdrawal) as monthly_bal
	from pivot_tbl
),
lead_tbl as (
	select *,LEAD(monthly_bal) OVER(PARTITION BY customer_id ORDER BY txn_month) as leading_bal  from m_bal
)
,perc_tbl as (
	select *,ROUND((100 * (leading_bal - monthly_bal)/abs(monthly_bal)),2) as percentage_change
	from lead_tbl 
	where leading_bal is not null
)
select ROUND(100*count(distinct customer_id)/(select count(distinct customer_id) from customer_transactions),2) as percentage_of_customers
from perc_tbl
where percentage_change >= 5;
