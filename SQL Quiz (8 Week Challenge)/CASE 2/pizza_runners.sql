--DATA PRE-PROCESSING SCRIPT WHICH IS REQUIRED FOR TWO TABLES customer_orders and runner_orders as the website suggested
CREATE TABLE ppd_customer_orders AS -- ppd means pre-processed data :D
SELECT order_id,customer_id,pizza_id,
	CASE
		when exclusions is null or exclusions like 'null' then ' '
		else exclusions
	end as exclusions,
	CASE 
		when extras is null or extras like 'null' then ' '
		else extras 
	end as extras,
	order_time
from customer_orders;

select * from ppd_customer_orders;

CREATE TABLE ppd_runner_orders AS 
SELECT order_id,runner_id,
	CASE 
		when pickup_time is null or pickup_time like 'null' then ' '
		else pickup_time
	end as pickup_time,
	CASE 
		when distance is null or distance like 'null' then ' '
		when distance ~ '^\d' then substring(distance from '^\d+\.?\d*')
		else distance
	end as distance,
	CASE 
		when duration is null or duration like 'null' then ' '
		when duration ~ '^\d' then substring(duration from '^\d+')
		else duration
	end as duration ,
	CASE 
		when cancellation is null or cancellation like 'null' then ' '
		else cancellation 
	end as cancellation
from runner_orders;

select * from runner_orders;
select * from ppd_runner_orders;


select * from ppd_customer_orders;
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;
select * from ppd_runner_orders;
select * from runners;

