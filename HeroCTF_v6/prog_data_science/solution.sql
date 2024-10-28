#Checking that all 200k records from the csv are loaded
select count(*) from heroctfv6.orders o ;
#Checking that there are no formatting issues in the records
select * from heroctfv6.orders o limit 50;

#If at 2019-12-31 (at the beginning) every person has 10000$, who has the most money by 2023-01-01 (transaction of that day excluded)? Answer: 732669

#This CTE will grab the amount of money spent for each id
with money_spent as (
  select buyer_id as person_id
       , sum(price - (price * (discount/100))) as money
  from heroctfv6.orders o
  where date < '2023-01-01'
  group by 1
)

#The CTE will grab the amount of money earned for each id
, money_earned as (
  select seller_id as person_id
       , sum(price - (price * (discount/100))) as money
  from heroctfv6.orders o
  where date < '2023-01-01'
  group by 1
)

#The final query will combine the money earned & spent for each id as well as adding 10,000 as an initial balance
# We order by total money descending to grab the id with the highest total money after all orders
SELECT 
    COALESCE(sp.person_id, e.person_id) AS person_id,
    10000 + COALESCE(e.money, 0) - COALESCE(sp.money, 0) AS total_money
FROM 
    money_spent sp
LEFT JOIN 
    money_earned e ON sp.person_id = e.person_id
UNION
SELECT 
    COALESCE(sp.person_id, e.person_id) AS person_id,
    10000 + COALESCE(e.money, 0) - COALESCE(sp.money, 0) AS total_money
FROM 
    money_spent sp
RIGHT JOIN 
    money_earned e ON sp.person_id = e.person_id
ORDER BY 
    total_money DESC;

#person_id 732669 is found to have the most money with $123,597.80 in above query


#2. By 2023-01-01 (transaction of that day excluded) how much money was spared through discounts? Answer: 188098001.8900 (round down to nearest whole number for answer)
select sum(price * (discount/100)) as amount_discounted
  from heroctfv6.orders o
  where date < '2023-01-01';
   
   
#3. By 2023-01-01 (transaction of that day excluded) how many people have a negative balance? 3468
 with money_spent as (
  select buyer_id as person_id
       , sum(price - (price * (discount/100))) as money
  from heroctfv6.orders o
  where date < '2023-01-01'
  group by 1
)

, money_earned as (
  select seller_id as person_id
       , sum(price - (price * (discount/100))) as money
  from heroctfv6.orders o
  where date < '2023-01-01'
  group by 1
)

#We can use the same CTEs as before but this time, we filter to records with total_money less than 0 and grab the count
SELECT count(*) FROM (
SELECT 
    COALESCE(sp.person_id, e.person_id) AS person_id,
    10000 + COALESCE(e.money, 0) - COALESCE(sp.money, 0) AS total_money
FROM 
    money_spent sp
LEFT JOIN 
    money_earned e ON sp.person_id = e.person_id
UNION
SELECT 
    COALESCE(sp.person_id, e.person_id) AS person_id,
    10000 + COALESCE(e.money, 0) - COALESCE(sp.money, 0) AS total_money
FROM 
    money_spent sp
RIGHT JOIN 
    money_earned e ON sp.person_id = e.person_id
ORDER BY 
    total_money DESC) x
where x.total_money < 0;