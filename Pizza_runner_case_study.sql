-- A. Pizza Metrics
-- 1.	How many pizzas were ordered?

select count(order_id) from customer_orders;

-- 2.	How many unique customer orders were made?

select count(distinct order_id) from customer_orders;

-- 3.	How many successful orders were delivered by each runner?

select runner_id,count(*) as successceful_orders 
from runner_orders
where coalesce(cancellation," ") not like '%cancellation'
group by runner_id;


-- 4.	How many of each type of pizza was delivered?

SELECT 
  p.pizza_name, 
  COUNT(c.pizza_id) AS delivered_pizza_count
FROM customer_orders AS c
JOIN runner_orders AS r
  ON c.order_id = r.order_id
JOIN pizza_names AS p
  ON c.pizza_id = p.pizza_id
WHERE r.distance != 0
GROUP BY p.pizza_name;

-- 5.	How many Vegetarians and Meatlovers were ordered by each customer?

select c.customer_id,p.pizza_name, count(*) count_pizza 
from customer_orders c
join pizza_names p on c.pizza_id = p.pizza_id
group by c.customer_id,p.pizza_name;

-- 6.	What was the maximum number of pizzas delivered in a single order?

select * from customer_orders;
select order_id, count(order_id) totalorders
from customer_orders
group by order_id
order by totalorders desc
limit 1;

-- 7.	For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

select customer_id, sum(case
						when nullif(exclusions, '' or 'null') is not null or nullif(extras, '' or 'null') is not null then 1 else 0 end) as changed,
                    sum(case 
						when nullif(exclusions, '' or 'null') is null and nullif(extras, '' or 'null') is null then 1 else 0 end) as unchanged
from customer_orders c 
where order_id in  (select order_id from runner_orders where coalesce(cancellation,"") not like '%cancellation') 
group by customer_id;

-- 8.	How many pizzas were delivered that had both exclusions and extras?

select count(*) from customer_orders
where nullif(exclusions, '' or 'null') is not null and nullif(extras, '' or 'null') is not null;


-- 9.	What was the total volume of pizzas ordered for each hour of the day?

SELECT 
  extract(HOUR from order_time) AS hour_of_day, 
  COUNT(order_id) AS pizza_count
FROM customer_orders
GROUP BY extract(HOUR from order_time);

-- 10.	What was the volume of orders for each day of the week?

select date_format(order_time,'%W') dayofweek, count(distinct order_id) order_volumes
from customer_orders
group by dayofweek;

#B. Runner and Customer Experience

#1.	How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
  FLOOR(DATEDIFF(registration_date, '2021-01-01') / 7) + 1 AS registration_week,
  COUNT(runner_id) AS runner_signup
FROM runners
GROUP BY registration_week
ORDER BY registration_week;

#2.	What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

select ro.runner_id,avg(timestampdiff(minute,c.order_time,ro.pickup_time)) as avg_time_pickup from customer_orders c
join runner_orders ro on c.order_id = ro.order_id
where ro.pickup_time != 'null'
group by ro.runner_id;

#3.	Is there any relationship between the number of pizzas and how long the order takes to prepare?

with cte1 as(
select co.order_id, count(co.pizza_id) as counts, 
co.order_time, 
ro.pickup_time,
timestampdiff(minute,order_time,pickup_time ) as preptime from customer_orders co
join runner_orders ro on ro.order_id = co.order_id
group by order_id,order_time,ro.pickup_time)
select counts,avg(preptime) as avg_preptime from cte1
group by counts;

#4.	What was the average distance travelled for each customer?
select c.customer_id, 
round(avg(nullif(ro.distance, 'null')),2) as avg_distance from runner_orders ro 
join customer_orders c on c.order_id = ro.order_id
group by c.customer_id;

#5.	What was the difference between the longest and shortest delivery times for all orders?
select concat(max(duration),'minutes') as max_dur,
min(duration) as min_dur, 
concat(max(duration)-min(duration),'minutes') as diff_dur 
from runner_orders
where duration != 'null';

#6.	What was the average speed for each runner for each delivery and do you notice any trend for these values?

select * from runner_orders;  -- convert duration into hours then speed equals distance by time 
select ro.runner_id,c.customer_id,c.order_id,
concat(round(ro.distance/(ro.duration/60),1),' kmph') as avg_speed 
from runner_orders ro
join customer_orders c using(order_id)
where distance != 'null' and duration != 'null' -- runnerc 2 is the fastest in delivering orders 
group by 1,2,3,4;

#7.	What is the successful delivery percentage for each runner?
select runner_id, count(order_id) as total_deliveries,
count(case when cancellation is null or cancellation = '' 
or cancellation = 'null' then 1 end) successful_orders,
round(count(case when cancellation is null or cancellation = '' 
or cancellation = 'null' 
then 1 end)/count(order_id)*100,2) as delivery_percent
from runner_orders
group by runner_id;

#C. Ingredient Optimisation
#1.	What are the standard ingredients for each pizza?

select pr.pizza_id, group_concat(pt.topping_name) as ingredients
from pizza_recipes pr
join pizza_toppings pt on find_in_set(pt.topping_id, replace(pr.toppings, ' ','')) >0
group by pr.pizza_id;

#2.	What was the most commonly added extra?

select * from customer_orders;
select temp.extra,pt.topping_name, count(temp.extra) as counts
from(select *,substr(extras,1,1) as extra from customer_orders) temp 
join pizza_toppings pt on pt.topping_id = temp.extra
group by temp.extra,pt.topping_name
having counts >1;

#3.	What was the most common exclusion?

select topping_name, count(topping_id) 
from customer_orders co
join pizza_toppings pt
on find_in_set(pt.topping_id, replace(co.exclusions,' ',''))>0
group by topping_name
limit 1;

#4.	Generate an order item for each record in the customers_orders table in the format of one of the following:
#o	Meat Lovers
#o	Meat Lovers - Exclude Beef
#o	Meat Lovers - Extra Bacon
#o	Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

SELECT 
    co.order_id,
    co.pizza_id,
    pn.pizza_name AS pizzaname,
    IFNULL(
        (
            SELECT CONCAT('exclude ', GROUP_CONCAT(DISTINCT pt.topping_name SEPARATOR ', '))
            FROM pizza_toppings pt
            WHERE 
                -- co.exclusions IS NOT NULL 
                -- AND co.exclusions != '' and
                FIND_IN_SET(pt.topping_id, REPLACE(co.exclusions, ' ', ''))>0 
        ),
        'none'
    ) AS exclusionname,
    IFNULL(
        (
            SELECT CONCAT('extra ', GROUP_CONCAT(DISTINCT pt.topping_name SEPARATOR ', '))
            FROM pizza_toppings pt
            WHERE 
               -- co.extras IS NOT NULL 
                -- AND co.extras != '' and
                FIND_IN_SET(pt.topping_id, REPLACE(co.extras, ' ', '')) > 0
        ),
        'none'
    ) AS extraname
FROM 
    customer_orders co
JOIN 
    pizza_names pn ON co.pizza_id = pn.pizza_id
GROUP BY 
    co.order_id, co.pizza_id, pn.pizza_name, co.exclusions, co.extras;

#5.	Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
#o	For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

with cte1 as (select co.order_id,co.pizza_id,co.exclusions,co.extras, pn.pizza_name,row_number() over () number_row 
from customer_orders co join pizza_names pn on co.pizza_id = pn.pizza_id),
 cte2 as (select c1.*,pr.toppings from cte1 c1 left join pizza_recipes pr on c1.pizza_id = pr.pizza_id),
 cte3 as (select * from cte2 c2 join pizza_toppings pt on find_in_set(pt.topping_id,replace(c2.toppings," ",""))>0),
 cte4 as (select * from cte3
 where not find_in_set(topping_id,replace(exclusions," ",""))>0),
 cte5 as (select *, case when find_in_set(topping_id,replace(extras," ",""))>0 
 then concat('2x',topping_name) else topping_name end as topping_names
 from cte4 )
 
 select order_id,pizza_name,group_concat(topping_names order by topping_names separator '  ') from cte5 
 group by order_id,pizza_name,exclusions,extras,number_row;
 

#6.	What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
with cte1 as (
    select distinct co.order_id, co.pizza_id, co.exclusions, co.extras, pn.pizza_name 
    from customer_orders co 
    join pizza_names pn on co.pizza_id = pn.pizza_id 
    join runner_orders ro on co.order_id = ro.order_id
    where ro.cancellation not like '%cancellation'
),
cte2 as ( -- here  we are adding/joining original recipe toppings
    select c1.*, pr.toppings 
    from cte1 c1 
    left join pizza_recipes pr on pr.pizza_id = c1.pizza_id
),
cte3 as ( -- here we need to find the topping id and their respecctive name right so joining topping_id to toppings
    select * 
    from cte2 c2 
    join pizza_toppings pt on find_in_set(pt.topping_id, replace(c2.toppings,' ','')) > 0
),
cte4 as ( -- we are removing exclusions from original toppings
    select * 
    from cte3 
    where not find_in_set(topping_id, replace(exclusions, ' ','')) > 0
),
cte5 as ( -- we are adding extras to toppings after exclusions are removed
    select *, 
    case 
        when find_in_set(topping_id, replace(extras, ' ','')) > 0 
        then concat('2x', topping_name) 
        else topping_name 
    end as toppingnames 
    from cte4
),
cte_final as ( -- counting the toppings
    select order_id, pizza_name, topping_name, 
    case 
        when find_in_set(topping_id, replace(extras, ' ','')) > 0 then 2 
        else 1 
    end as topping_count
    from cte5
),
total as (select  -- this is to sum total count 
    topping_name, 
    sum(topping_count) as total_usage
from cte_final
group by topping_name
order by total_usage desc)
select *, sum(total_usage) over() as total
from total;


#D. Pricing and Ratings

#1.	If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
with cte1 as(select co.order_id,r.runner_id,co.pizza_id,pn.pizza_name, 
case
	when co.pizza_id = 1 then 12 else 10 end as price
from customer_orders co left join runner_orders r on r.order_id= co.order_id
join pizza_names pn on pn.pizza_id = co.pizza_id
where r.cancellation not like '%cancellation' or r.cancellation is null)

select runner_id, concat('$ ',sum(price)) total_earnings
from cte1
group by runner_id
order by runner_id;

#2.	What if there was an additional $1 charge for any pizza extras?
#o	Add cheese is $1 extra

with cte1 as(select co.order_id,r.runner_id,co.pizza_id,pn.pizza_name,co.exclusions,co.extras,
CASE 
        WHEN exclusions IS NULL THEN 0
        WHEN exclusions = '' THEN 0
        when exclusions = 'null' then 0 
        ELSE (LENGTH(exclusions)+1 - LENGTH(REPLACE(exclusions, ',', '')))
    END AS price_for_exclusions,
CASE 
        WHEN extras IS NULL THEN 0
        WHEN extras = '' THEN 0
        when extras = 'null' then 0 
        ELSE (LENGTH(extras)+1 - LENGTH(REPLACE(extras, ',', '')))
    END AS price_for_extras,
case
	when co.pizza_id = 1 then 12 else 10 end as price
from customer_orders co left join runner_orders r on r.order_id= co.order_id
join pizza_names pn on pn.pizza_id = co.pizza_id
left join pizza_toppings pt on pt.topping_id = co.exclusions
where r.cancellation not like '%cancellation' or r.cancellation is null),

cte2 as(select runner_id,price_for_exclusions,price_for_extras,price,((price+price_for_extras)) as final_price 
from cte1)
select runner_id, sum(final_price) as final_earnings
from cte2
group by runner_id
order by runner_id;

#3.	The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
#how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful 
#customer order between 1 to 5.
create table customer_ratings (customer_id int, order_id int,order_time datetime,runner_id int, rating int check(rating between 0 and 5));

#4.	Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
#o	customer_id
#o	order_id
#o	runner_id
#o	rating
#o	order_time
#o	pickup_time
#o	Time between order and pickup
#o	Delivery duration
#o	Average speed
#o	Total number of pizzas


with cte1 as (
select co.customer_id, co.order_id,co.pizza_id,r.runner_id,
co.order_time,r.pickup_time,cr.rating,r.duration,r.distance
from customer_orders co
left join runner_orders r on r.order_id = co.order_id
left join customer_ratings cr on cr.order_id=co.order_id
where r.pickup_time != 'null'),
cte2 as(
select c1.*,timestampdiff(minute,order_time,pickup_time) as time_diffe,
distance/(duration/60) as speed from cte1 c1)

select customer_id,order_id,runner_id,rating,order_time,pickup_time,time_diffe,duration,
floor(avg(speed) over(partition by runner_id)) as avg_speed,
count(pizza_id) as total_pizzas from cte2
group by customer_id,order_id,runner_id,speed,rating,order_time,pickup_time,time_diffe,duration
order by order_id;

#5.	If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per 
#kilometre travelled - how much money does Pizza Runner have left over after these deliveries?

with cte1 as(
select co.order_id,co.pizza_id,r.runner_id,r.distance,
round(r.distance*0.30,1) as deliverycharge,
case 
	when co.pizza_id = 1 then 12 else 10 end as cost
from customer_orders co
left join runner_orders r on r.order_id=co.order_id
where r.distance != 'null'),
cte2 as (select runner_id,deliverycharge,sum(cost) as total_cost
from cte1
group by order_id,runner_id,distance,deliverycharge)
select sum(total_cost-deliverycharge) as final_earnings from cte2;

