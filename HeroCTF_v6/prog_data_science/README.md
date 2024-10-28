# 🏆 **CTF Challenge Write-Up: Data Science**
<div align="right"><img src="https://github.com/user-attachments/assets/6de983de-e96f-4462-85d7-f56d5817496d"/></div>

## 📋 Challenge Information 

**CTF:** HeroCTF_v6 

**Challenge Name:** Data Science

**Category:** Programming/SQL

**Description:**
Here is a database of sells on a online marketplace. Your job as a data analyst is to answer the following questions :
1. If at 2019-12-31 (at the beginning) every person has 10000$, who has the most money by 2023-01-01 (transaction of that day excluded)?
2. By 2023-01-01 (transaction of that day excluded) how much money was spared through discounts?
3. By 2023-01-01 (transaction of that day excluded) how many people have a negative balance?


Here are some information about the database fields:
| Field name | Data type | Constraints |
|------------|------------|-------------------------|
| order_id | integer | 1 < order_id < 1 000 000|
| buyer_id | integer | 1 < buyer_id < 1 000 000|
| seller_id | integer | 1 < seller_id < 1 000 000|
| price | integer | 1 < price < 10 000 |
| discount | integer | 0 < discount < 100 |
| date | date | yyyy-mm-dd |


Additionally, you should know that Buyers and Sellers are reprensted by a unique ID and are correlated. Buyer 163564 is the same person as Seller 163564.


Prices should be floored to the nearest integer, but only at the final stage of the calculation.


e.g. If there are two discounts bringing prices down from 10 and 5 to 8.64 and 4.32 respectively, the amount of money spared is 10 + 5 - 8.64 - 4.32 = 2.04 ~= 2. As you can see, the only rounding operation was done on the very last value, used in the flag.


The flag is Hero{response1_response2_reponse3}.


e.g. Hero{163564_21673_78}

**Provided files:**
* orders.csv

---
<br><br><br>
## 🔍 Reconnaissance and Initial Setup

**Observations:** 
The file contains information about people (identified by their buyer/seller ids) and their orders from each other. We are given information about who bought/sold to each other and for how much. We are also given the date of the order and the amount of any discount applied. Because the discount is defined as an integer from 0 to 100, I've interpretted these to be percentages.

**Plan:**
1. Calculate the net profit/loss of each person's id for question 1
2. Find the sum of all discounts applied
3. Find number of people with a negative balance

**Requirements:**

I set up a local MySQL database and created a table "orders" with the columns as defined in the problem description and populated it with the data in the provided csv:

![image](https://github.com/user-attachments/assets/aea55b05-a4d8-413d-9fe8-4622fc757cbc)
<br>


---
<br><br><br>
## 🛠️ Step-by-Step Solution

### Step 1: Calculate the net profit/loss of each person's ID

**Question 1:** If at 2019-12-31 (at the beginning) every person has 10000$, who has the most money by 2023-01-01 (transaction of that day excluded)?

In order to answer this question, we need to first find how we will calculate the total amount of money being transacted in each order. Because "discount" is a percentage, we can calculate the total cost as the price of the order minus the discounted amount:
```sql
price - (price * (discount/100))
```
<br>

To calculate the total amount of money each person has by 2023-01-01, I wrote the following query:
```sql
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
```
<br>

![image](https://github.com/user-attachments/assets/084da321-c275-4c16-8823-b4c35f320d92)

<br>

This query shows us that person_id >>**732669**<< is found to have the most money with $123,597.80.

<br><br>
<hr>

### Step 2: Find the sum of all discounts applied

**Question 2:** By 2023-01-01 (transaction of that day excluded) how much money was spared through discounts?

We already have the logic for finding the discount for each order:
```sql
(price * (discount/100))
```
<br>

Now, all we need to do is take the sum of all discounts in the desired date range:
```sql
select sum(price * (discount/100)) as amount_discounted
  from heroctfv6.orders o
  where date < '2023-01-01';
```
<br>

![image](https://github.com/user-attachments/assets/38d6ad01-f288-4b64-ba16-423f0cd632a3)

<br>

Here we can see that the sum of all discounts is 188098001.8900. We will be flooring this value to >>**188098001**<< as requested in the challenge defintion.

<br><br>
<hr>

### Step 3: Find number of people with a negative balance

**Question 3:** By 2023-01-01 (transaction of that day excluded) how many people have a negative balance?

We can reuse our query from step 1 to get the balance for every person's id. This time we will be filtering to id's that have a balance of less than 0 and taking the count of ids.
```sql
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
```
<br>

![image](https://github.com/user-attachments/assets/2b5f5645-fb06-491e-af97-6789bfb0eb7e)

<br>

Here we can see that total number of ids with a negative balance is >>**3468**<<.

---
<br><br>

## 🏁 Flag Creation

The final step is combining the values from our 3 steps as requested in the challenge definition.

**Flag:** Hero{732669_188098001_3468}
