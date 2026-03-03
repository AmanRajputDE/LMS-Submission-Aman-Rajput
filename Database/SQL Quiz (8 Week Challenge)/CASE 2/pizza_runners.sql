--DATA PRE-PROCESSING SCRIPT WHICH IS REQUIRED FOR TWO TABLES customer_orders and runner_orders as the website suggested
CREATE TABLE ppd_customer_orders AS -- ppd means pre-processed data :D
SELECT order_id,customer_id,pizza_id,
	CASE
		when exclusions is null or exclusions like 'null' then ''
		else exclusions
	end as exclusions,
	CASE 
		when extras is null or extras like 'null' then ''
		else extras 
	end as extras,
	order_time
from customer_orders;

select * from ppd_customer_orders;

drop table ppd_runner_orders;

CREATE TABLE ppd_runner_orders AS 
SELECT order_id,runner_id,
	CASE 
		when pickup_time is null or pickup_time like 'null' then ''
		else pickup_time
	end as pickup_time,
	CASE 
		when distance is null or distance like 'null' then ''
		when distance ~ '^\d' then substring(distance from '^\d+\.?\d*')
		else distance
	end as distance,
	CASE 
		when duration is null or duration like 'null' then ''
		when duration ~ '^\d' then substring(duration from '^\d+')
		else duration
	end as duration ,
	CASE 
		when cancellation is null or cancellation like 'null' then ''
		else cancellation 
	end as cancellation
from runner_orders;

select * from runner_orders;
select * from ppd_runner_orders;

-- Handling the data type
update ppd_runner_orders
set pickup_time = NULL
where TRIM(pickup_time) = '';

update ppd_runner_orders
set distance = NULL
where TRIM(distance) = '';

update ppd_runner_orders
set duration = NULL
where TRIM(duration) = '';

update ppd_runner_orders
set cancellation = NULL
where TRIM(cancellation) = '';

ALTER TABLE ppd_runner_orders
ALTER COLUMN distance TYPE FLOAT USING distance::double precision;

ALTER TABLE ppd_runner_orders
ALTER COLUMN duration TYPE INTEGER USING duration::integer;

ALTER TABLE ppd_runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::timestamp without time zone;

UPDATE ppd_customer_orders
SET exclusions = NULL
WHERE TRIM(exclusions) = '';

UPDATE ppd_customer_orders
SET extras = NULL
WHERE TRIM(extras) = '';

-- Pizza Metrics

--1. How many pizzas were ordered?
select count(*) as total_pizza_ordered
from ppd_customer_orders;

--2. How many unique customer orders were made?
select count(distinct order_id) as unique_customer_order
from ppd_customer_orders;

--3.How many successful orders were delivered by each runner?
select runner_id, count(*) as successful_orders
from ppd_runner_orders
where cancellation is null
group by runner_id;

--4. How many of each type of pizza was delivered?
with pizza_delivered as (
	select pizza_id,count(*) as count_of_pizza_delivered
	from ppd_customer_orders 
	where order_id in (
		select order_id
		from ppd_runner_orders
		where cancellation is null
	)
	group by pizza_id
)
select pn.pizza_id,pizza_name, count_of_pizza_delivered
from pizza_names pn
left join pizza_delivered pd
on pn.pizza_id = pd.pizza_id

--5. How many Vegetarian and Meatlovers were ordered by each customer?
with count_tbl as (
	select customer_id,pizza_id,count(*) as no_of_pizza_ordered
	from ppd_customer_orders
	group by customer_id,pizza_id
	order by customer_id,pizza_id
),
customers as (
	select distinct customer_id
	from ppd_customer_orders
),
cus_pizza as (
	select *
	from customers
	cross join pizza_names
	order by customer_id,pizza_id
)
select cp.customer_id, cp.pizza_id, cp.pizza_name,coalesce(ctbl.no_of_pizza_ordered,0) as no_of_pizza_ordered
from cus_pizza cp
left join count_tbl ctbl
on cp.pizza_id = ctbl.pizza_id and cp.customer_id = ctbl.customer_id
order by cp.customer_id,cp.pizza_id


--6. What was the maximum number of pizzas delivered in a single order?

select order_id, count(*) as no_of_pizzas
from ppd_customer_orders
where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
group by order_id
order by no_of_pizzas DESC
FETCH FIRST 1 ROW ONLY;

--7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

with changes as (
	select *,
	CASE 
		when exclusions is null and extras is null then 1
		else 0
	end as no_changes,
	CASE 
		when exclusions is not null or extras is not null then 1
		else 0
	end as atleast_one_change
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
	order by order_id
)
select customer_id,sum(no_changes) as no_changes, sum(atleast_one_change) as atleast_one_change
from changes
group by customer_id;

--8. How many pizzas were delivered that had both exclusions and extras?

select
	SUM(
		CASE 
			when exclusions is not null and extras is not null then 1
			else 0
		end 
	) as no_of_pizza_delivered_having_both_exclusions_and_extras
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null);

--9. What was the total volume of pizzas ordered for each hour of the day?

with hr_of_day as (
	select *,EXTRACT(hours from order_time) as hour_of_the_day
	from ppd_customer_orders
)
select hour_of_the_day, count(*) as volume_of_pizzas_ordered
from hr_of_day
group by hour_of_the_day;

--10. What was the volume of orders for each day of the week?

with dow as (
	select *,EXTRACT(isodow from order_time) as day_of_week
	from ppd_customer_orders
)
select day_of_week,count(*) as volume_of_orders
from dow
group by day_of_week

-- Runner and Customer Experience
--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT (DATE '2021-01-01' + (((registration_date - DATE '2021-01-01') / 7)::int) * 7) AS week_start,
	count(*) as sign_ups_per_week
from runners
group by week_start
order by week_start;

--2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

with successfull_orders as (
	select DISTINCT order_id, order_time
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
),
time_diff as (
	select so.order_id,so.order_time,runner_id,pickup_time,AGE(pickup_time,order_time) as pickup_order_diff
	from successfull_orders so
	left join ppd_runner_orders pro
	on so.order_id = pro.order_id
)
select runner_id, EXTRACT(MINUTE FROM AVG(pickup_order_diff)) as AVG_TIME_IN_MINUTE_BTW_order_and_pickup
from time_diff
group by runner_id;


--3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

with successfull_orders as (
	select DISTINCT order_id, order_time
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
),
prep as (
select so.order_id,so.order_time,runner_id,pickup_time,AGE(pickup_time,order_time) as prep_time
	from successfull_orders so
	left join ppd_runner_orders pro
	on so.order_id = pro.order_id
),
num_of_orders_tbl as (
	select order_id,count(*) as num_of_pizzas
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
	group by order_id
)
select corr(EXTRACT(EPOCH FROM prep_time)/ 60,num_of_pizzas) as correlation_between_prep_time_and_num_of_pizzas
from prep p
inner join num_of_orders_tbl notbl
on p.order_id = notbl.order_id;

--4. What was the average distance travelled for each customer?

select customer_id, ROUND(AVG(distance)::decimal,2) as Avg_distance_travelled
from ppd_customer_orders pco
inner join ppd_runner_orders pro
on pco.order_id = pro.order_id
where cancellation is null
group by customer_id;

--5. What was the difference between the longest and shortest delivery times for all orders?

select MAX(duration) - MIN(duration) as diff_delivery_times
from ppd_runner_orders;

--6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

select order_id,runner_id,
ROUND(((distance * 60)/duration)::decimal,2) as speed
from ppd_runner_orders
where cancellation is null;

--7. What is the successful delivery percentage for each runner?

select runner_id,(100*SUM(
CASE 
	when cancellation is null then 1 
	else 0
end)/count(*)) as successful_delivery_percentage
from ppd_runner_orders
group by runner_id;

--Ingredient Optimisation

--1. What are the standard ingredients for each pizza?

with ppd_pizza_recipes as (
	select pizza_id,
	trim(
			unnest(
				string_to_array(toppings,',')
			)
		)::integer as topping_id
	from pizza_recipes
)
select pizza_id,
	array_to_string(ARRAY_AGG(topping_name),',') as topping_name
from ppd_pizza_recipes ppdpr
inner join pizza_toppings pt
on ppdpr.topping_id = pt.topping_id
group by pizza_id
order by pizza_id;

--2. What was the most commonly added extra?

with eti as (
	select trim(unnest(string_to_array(extras,',')))::integer as extras_topping_id
	from ppd_customer_orders
	where extras is not null
)
select eti.extras_topping_id,topping_name,COUNT(*) as no_of_times_ordered_as_extras
from eti
inner join pizza_toppings pt
on eti.extras_topping_id = pt.topping_id
group by eti.extras_topping_id,topping_name
order by no_of_times_ordered_as_extras DESC
FETCH FIRST 1 ROW ONLY;

--3. What was the most common exclusion?

with eti as (
	select trim(unnest(string_to_array(exclusions,',')))::integer as exclusions_topping_id
	from ppd_customer_orders
	where exclusions is not null
)
select eti.exclusions_topping_id,topping_name,COUNT(*) as no_of_times_excluded
from eti
inner join pizza_toppings pt
on eti.exclusions_topping_id = pt.topping_id
group by eti.exclusions_topping_id,topping_name
order by no_of_times_excluded DESC
FETCH FIRST 1 ROW ONLY;

--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--	 Meat Lovers
--	 Meat Lovers - Exclude Beef
--	 Meat Lovers - Extra Bacon
--	 Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

with ppd_customer_orders_rn as (
	select *,ROW_NUMBER() OVER(
	PARTITION BY order_id
	ORDER BY order_time) as r_num
from ppd_customer_orders
)
,id_tbl as (
	select order_id,customer_id,pizza_id,
			trim(unnest(string_to_array(exclusions,',')))::int as exclusions,
			trim(unnest(string_to_array(extras,',')))::int as extras,
			order_time,r_num
	from ppd_customer_orders_rn
		UNION all
	select order_id,customer_id,pizza_id,exclusions::int,extras::int, order_time,r_num
	from ppd_customer_orders_rn
	where exclusions is null and extras is null
	order by order_id
)
,name_tbl as (
	select id_tbl.order_id,id_tbl.customer_id,pizza_name, pt.topping_name as exclusions_name, pt1.topping_name,r_num
	from id_tbl 
	inner join pizza_names pn 
		on id_tbl.pizza_id = pn.pizza_id
	left join pizza_toppings pt
		on id_tbl.exclusions = pt.topping_id
	left join pizza_toppings pt1
		on id_tbl.extras = pt1.topping_id
	order by order_id
)
,agg_tbl as (
select order_id,customer_id,pizza_name,r_num,
	array_to_string(ARRAY_AGG(exclusions_name),', ') as exclusions_name, 
	array_to_string(ARRAY_AGG(topping_name),', ') as topping_name
from name_tbl
group by order_id,customer_id,pizza_name,r_num
order by order_id
)
select order_id,customer_id,
	CASE 
		when exclusions_name LIKE '' and topping_name LIKE '' then pizza_name
		when exclusions_name NOT LIKE '' and topping_name LIKE '' then CONCAT(pizza_name,' - Exclude ',exclusions_name)
		when exclusions_name LIKE '' and topping_name NOT LIKE '' then CONCAT(pizza_name,' - Extra ',topping_name)
		when exclusions_name NOT LIKE '' and topping_name NOT LIKE '' then CONCAT(pizza_name,' - Exclude ',exclusions_name,' - Extra ',topping_name)
	END as order_description
FROM agg_tbl;


--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the 
--customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with ppd_customer_orders_rn as (
	select *,ROW_NUMBER() OVER(
	PARTITION BY order_id
	ORDER BY order_time) as r_num
from ppd_customer_orders
)
,arr_tbl as (
	select order_id,
		customer_id,
		pp.pizza_id,
		string_to_array(exclusions,', ')::int[] as exclusions,
		string_to_array(extras,', ')::int[] as extras,
		string_to_array(pr.toppings,', ')::int[] as std_ing,
		order_time,
		r_num
	from ppd_customer_orders_rn pp
	left join pizza_recipes pr
	on pp.pizza_id = pr.pizza_id
	order by order_id
)
,ing_ext_tbl as (
	select *,std_ing || extras as ing_extras
	from arr_tbl
)
, ing_ext_exc_tbl as (
	select *,
	CASE 
		when exclusions is not null then ARRAY( SELECT x FROM unnest(ing_extras) as x WHERE NOT x = ANY(exclusions))
		else ing_extras
	end as result_ing
	FROM ing_ext_tbl
)
, ing_tbl as (
	select order_id,customer_id,pizza_id,r_num,unnest(result_ing) as ing
	from ing_ext_exc_tbl
)
, freq_top as (
	select order_id,customer_id,pizza_name,topping_name,r_num,count(*) as freq_topping
	from ing_tbl itbl
	left join pizza_names pn 
		ON itbl.pizza_id = pn.pizza_id
	left join pizza_toppings pt
		on itbl.ing = pt.topping_id
	group by order_id,customer_id,pizza_name,topping_name,r_num
	order by order_id,topping_name
)
,topp_n_freq as (
	select *,
	CASE
		when freq_topping > 1 then concat(freq_topping,'x',topping_name) 
		else topping_name
	end as topp_freq
	from freq_top
)
select order_id,customer_id,pizza_name,r_num,array_to_string(ARRAY_AGG(topp_freq),', ')
from topp_n_freq
group by order_id,customer_id,pizza_name,r_num;

--6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

with ppd_customer_orders_rn as (
	select *,ROW_NUMBER() OVER(
	PARTITION BY order_id
	ORDER BY order_time) as r_num
from ppd_customer_orders
)
,arr_tbl as (
	select order_id,
		customer_id,
		pp.pizza_id,
		string_to_array(exclusions,', ')::int[] as exclusions,
		string_to_array(extras,', ')::int[] as extras,
		string_to_array(pr.toppings,', ')::int[] as std_ing,
		order_time,
		r_num
	from ppd_customer_orders_rn pp
	left join pizza_recipes pr
	on pp.pizza_id = pr.pizza_id
	order by order_id
)
,ing_ext_tbl as (
	select *,std_ing || extras as ing_extras
	from arr_tbl
)
, ing_ext_exc_tbl as (
	select *,
	CASE 
		when exclusions is not null then ARRAY( SELECT x FROM unnest(ing_extras) as x WHERE NOT x = ANY(exclusions))
		else ing_extras
	end as result_ing
	FROM ing_ext_tbl
)
, ing_tbl as (
	select order_id,customer_id,pizza_id,r_num,unnest(result_ing) as ing
	from ing_ext_exc_tbl
)
, final as (
	select topping_name,count(*) as freq_topping
	from ing_tbl itbl
	left join pizza_names pn 
		ON itbl.pizza_id = pn.pizza_id
	left join pizza_toppings pt
		on itbl.ing = pt.topping_id
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
	group by topping_name
)
select *
from final 
order by freq_topping DESC;

-- Pricing and Ratings

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there 
-- were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

with freq_pizza as (
	select pco.pizza_id,pizza_name,count(*) as freq_pizza
	from ppd_customer_orders pco
	inner join pizza_names pn
	on pco.pizza_id = pn.pizza_id
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
	group by pco.pizza_id,pizza_name
)
, capital as (
	select *,
		CASE 
			when pizza_name = 'Meatlovers' then freq_pizza * 12 
			when pizza_name = 'Vegetarian' then freq_pizza * 10
		END as capital_earned
	from freq_pizza
)
select sum(capital_earned) as total_amount_earned
from capital

--2. What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

with ppd_customer_orders_rn as (
	select *,ROW_NUMBER() OVER(
	PARTITION BY order_id
	ORDER BY order_time) as r_num
from ppd_customer_orders
)
,arr_tbl as (
	select order_id,
		customer_id,
		pp.pizza_id,
		string_to_array(exclusions,', ')::int[] as exclusions,
		string_to_array(extras,', ')::int[] as extras,
		string_to_array(pr.toppings,', ')::int[] as std_ing,
		order_time,
		r_num
	from ppd_customer_orders_rn pp
	left join pizza_recipes pr
	on pp.pizza_id = pr.pizza_id
	order by order_id
)
,ing_ext_tbl as (
	select *,std_ing || extras as ing_extras
	from arr_tbl
)
, ing_ext_exc_tbl as (
	select *,
	CASE 
		when exclusions is not null then ARRAY( SELECT x FROM unnest(ing_extras) as x WHERE NOT x = ANY(exclusions))
		else ing_extras
	end as result_ing
	FROM ing_ext_tbl
)
, ing_tbl as (
	select order_id,customer_id,pizza_id,r_num,unnest(result_ing) as ing
	from ing_ext_exc_tbl
)
,is_chs as (
	select order_id,customer_id,itbl.pizza_id,r_num,pizza_name,
		CASE 
			when topping_name = 'Cheese' then 1 
			else 0
		END as is_cheese
	from ing_tbl itbl
	left join pizza_names pn 
		ON itbl.pizza_id = pn.pizza_id
	left join pizza_toppings pt
		on itbl.ing = pt.topping_id
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
)
, ext_chs as (
	select order_id,customer_id,pizza_id,pizza_name,r_num,sum(is_cheese) as extra_cheese_price
	from is_chs
	group by order_id,customer_id,pizza_id,pizza_name,r_num
)
, price as (
	select pizza_name,count(*) as freq_orders,SUM(extra_cheese_price) as ext_cheese_price
	from ext_chs
	group by pizza_name
)
, final_tbl as (
	select *,
		CASE
			when pizza_name = 'Meatlovers' then freq_orders*12 + ext_cheese_price
			when pizza_name = 'Vegetarian' then freq_orders*10 + ext_cheese_price
		end as capital_earned
	from price
)
select sum(capital_earned) as total_amount_earned
from final_tbl;

--3. The Pizza Runner team now wants to add an additional ratings system that 
-- allows customers to rate their runner, how would you design an additional table for this
-- new dataset - generate a schema for this new table and insert your own data for ratings 
-- for each successful customer order between 1 to 5.

CREATE TABLE ratings (
	order_id integer,
	rating integer
);

INSERT INTO ratings 
VALUES (1,3),
	(2,4),
	(3,5),
	(4,4),
	(5,3),
	(7,1),
	(8,4),
	(10,5);

select * from ratings;

--4. Using your newly generated table - can you join all of the information together 
--to form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating							
-- order_time					 	
-- pickup_time 						
-- Time between order and pickup	o
-- Delivery duration 				
-- Average speed					
-- Total number of pizzas			

with orders as (
	select order_id,customer_id,order_time,count(*) as tot_num_of_pizzas
	from ppd_customer_orders
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
	group by order_id,customer_id,order_time
)
select customer_id,
	o.order_id,
	runner_id,
	rating,
	order_time,
	pickup_time,
	(pickup_time - order_time) as Time_between_order_and_pickup,
	duration as Delivery_duration, 
	ROUND(((distance * 60)/duration)::decimal,2) as Speed,
	tot_num_of_pizzas as Total_number_of_pizzas
from orders o
left join ppd_runner_orders pro
	on o.order_id = pro.order_id
left join ratings r
	on o.order_id = r.order_id;


--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with 
-- no cost for extras and each runner is paid $0.30 per kilometre traveled - 
-- how much money does Pizza Runner have left over after these deliveries?


with pizza_price as (
	select *,
	CASE
		when pizza_id = 1 then 12
		when pizza_id = 2 then 10
	END as price
	from ppd_customer_orders pco
	where order_id not in (select order_id from ppd_runner_orders where cancellation is not null)
)
,order_price as (
	select order_id,sum(price) as pizza_cost
	from pizza_price
	group by order_id
),
del_cost as (
	select *,(distance * 0.3) as delivery_cost
	from order_price op
	left join ppd_runner_orders pro
	on op.order_id = pro.order_id
)
select ROUND(SUM(pizza_cost - delivery_cost)::decimal,2) as net_profit
from del_cost;

--Bonus Questions
-- If Danny wants	 to expand his range of pizzas - 
-- how would this impact the existing data design? Write an INSERT statement 
-- to demonstrate what would happen if a new Supreme pizza with all 
-- the toppings was added to the Pizza Runner menu?

INSERT INTO pizza_recipes 
VALUES (3,'1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12');


