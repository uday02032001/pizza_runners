
-- The runners table shows the registration_date for each new runner
DROP TABLE runners;

CREATE TABLE runners (
  runner_id NUMBER(6),
  registration_date DATE
);

INSERT INTO runners (runner_id, registration_date) VALUES  (1, TO_DATE('2021-01-01','YYYY-MM-DD'));
INSERT INTO runners (runner_id, registration_date) VALUES  (2, TO_DATE('2021-01-03','YYYY-MM-DD'));
INSERT INTO runners (runner_id, registration_date) VALUES  (3, TO_DATE('2021-01-08','YYYY-MM-DD'));
INSERT INTO runners (runner_id, registration_date) VALUES  (4, TO_DATE('2021-01-15','YYYY-MM-DD'));

-- Customer pizza orders are captured in the customer_orders table with 1 row for each individual pizza that is part of the order.
DROP TABLE customer_orders;
CREATE TABLE customer_orders (
  order_id NUMBER(6),
  customer_id NUMBER(6),
  pizza_id NUMBER(6),
  exclusions VARCHAR2(4),
  extras VARCHAR2(4),
  order_time TIMESTAMP
);


INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (1, 101, 1, '', '', TO_DATE('2020-01-01 18:05:02','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (2, 101, 1, '', '', TO_DATE('2020-01-01 19:00:52','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (3, 102, 1, '', '', TO_DATE('2020-01-02 23:51:23','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (3, 102, 2, '', null, TO_DATE('2020-01-02 23:51:23','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (4, 103, 1, '4', '', TO_DATE('2020-01-04 13:23:46','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (4, 103, 1, '4', '', TO_DATE('2020-01-04 13:23:46','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (4, 103, 2, '4', '', TO_DATE('2020-01-04 13:23:46','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (5, 104, 1, null, '1', TO_DATE('2020-01-08 21:00:29','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (6, 101, 2, null, null,TO_DATE( '2020-01-08 21:03:13','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (7, 105, 2, null, '1', TO_DATE('2020-01-08 21:20:29','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (8, 102, 1, null, null, TO_DATE('2020-01-09 23:54:33','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (9, 103, 1, '4', '1, 5', TO_DATE('2020-01-10 11:22:59','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (10,104, 1, null, null, TO_DATE('2020-01-11 18:34:49','YYYY-MM-DD HH24:MI:SS'));
INSERT INTO customer_orders (order_id, customer_id, pizza_id, exclusions, extras, order_time) VALUES (10,104, 1, '2, 6', '1, 4', TO_DATE('2020-01-11 18:34:49','YYYY-MM-DD HH24:MI:SS'));

  
-- After each orders are received through the system - they are assigned to a runner - however not all orders are fully completed and can be cancelled by the restaurant or the customer.
DROP TABLE runner_orders;
  
CREATE TABLE runner_orders (
  order_id NUMBER(6),
  runner_id NUMBER(6),
  pickup_time VARCHAR2(19),
  distance VARCHAR2(7),
  duration VARCHAR2(10),
  cancellation VARCHAR2(23)
);

INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (1, 1, TO_DATE('2020-01-01 18:15:34','YYYY-MM-DD HH24:MI:SS'), '20km', '32 minutes', '');
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (2, 1, TO_DATE('2020-01-01 19:10:54','YYYY-MM-DD HH24:MI:SS'), '20km', '27 minutes', '');
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (3, 1, TO_DATE('2020-01-03 00:12:37','YYYY-MM-DD HH24:MI:SS'), '13.4km', '20 mins', null);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (4, 2, TO_DATE('2020-01-04 13:53:03','YYYY-MM-DD HH24:MI:SS'), '23.4', '40', null);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (5, 3, TO_DATE('2020-01-08 21:10:57','YYYY-MM-DD HH24:MI:SS'), '10', '15', null);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (6, 3, null, null, null, 'Restaurant Cancellation');
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (7, 2, TO_DATE('2020-01-08 21:30:45','YYYY-MM-DD HH24:MI:SS'), '25km', '25mins', null);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (8, 2, TO_DATE('2020-01-10 00:15:02','YYYY-MM-DD HH24:MI:SS'), '23.4 km', '15 minute', null);
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (9, 2, null, null, null, 'Customer Cancellation');
INSERT INTO runner_orders (order_id, runner_id, pickup_time, distance, duration, cancellation) VALUES  (10,1,TO_DATE('2020-01-11 18:50:20','YYYY-MM-DD HH24:MI:SS'), '10km', '10minutes', null);

-- Pizza Runner only has 2 pizzas available the Meat Lovers or Vegetarian!
DROP TABLE pizza_names;

CREATE TABLE pizza_names (
  pizza_id NUMBER(6),
  pizza_name VARCHAR2(30)
);

INSERT INTO pizza_names  (pizza_id, pizza_name) VALUES (1, 'Meatlovers');
INSERT INTO pizza_names  (pizza_id, pizza_name) VALUES (2, 'Vegetarian');

-- Each pizza_id has a standard set of toppings which are used as part of the pizza recipe.
DROP TABLE pizza_recipes;

CREATE TABLE pizza_recipes (
  pizza_id NUMBER(6),
  toppings VARCHAR2(30)
);

INSERT INTO pizza_recipes (pizza_id, toppings) VALUES  (1, '1, 2, 3, 4, 5, 6, 8, 10');

INSERT INTO pizza_recipes (pizza_id, toppings) VALUES  (2, '4, 6, 7, 9, 11, 12');

-- table contains all of the topping_name values with their corresponding topping_id value
DROP TABLE pizza_toppings;

CREATE TABLE pizza_toppings (
  topping_id NUMBER(6),
  topping_name VARCHAR2(50)
);

INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (1, 'Bacon');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (2, 'BBQ Sauce');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (3, 'Beef');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (4, 'Cheese');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (5, 'Chicken');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (6, 'Mushrooms');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (7, 'Onions');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (8, 'Pepperoni');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (9, 'Peppers');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (10, 'Salami');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (11, 'Tomatoes');
INSERT INTO pizza_toppings (topping_id, topping_name) VALUES  (12, 'Tomato Sauce');

COMMIT;