select * from maintenance;
select * from production where units_produced > (
select avg(units_produced)
from production
);

-- find production records where units_produced is greater than
-- the maximum units produced in the entire table
select units_produced from production
where units_produced > (
select max(units_produced) from production);

-- find all production records where
-- units_produced is greater than the avg production across all records
select * from production
where units_produced > (
select avg(units_produced) from production
);

-- find all production records belonging to machines that have produced more than 20 
-- units in atleast one production record
select * from production
where machine_id IN (
select machine_id from production
where units_produced > 20);


-- find all production records where units_produced is greater than the avg
-- units produced across the entire prouction table
select * from production 
where units_produced > (
select avg(units_produced) from production);


-- find all the products whose selling_price is greater than the avg selling
-- price of all products
select * from products
where selling_price > (select avg(selling_price) from products);

-- find all production records belonging to machines that have produced more than
-- 20 units in al least one production record
select * from production
where machine_id in (select machine_id from production
where units_produced > 20);

-- find products that have never appeared in the production table
select * from products
where product_id not in (select product_id from production);

-- find all machines that have never had a maintenance record
select machine_id,machine_name from machines
where machine_id not in (select machine_id from maintenance);

-- find each machine's total units produced,
-- then display only machins whose total exceeds 30 units
with machine_total as (
select machine_id, sum(units_produced) as total_units
from production
Group by machine_id
)
select machine_id, total_units
from machine_total 
where total_units>30;

-- find each product category's total_units_produced,
-- then display only cateogories with more than 300 units
with product_categorys as (
p.category, sum(pr.units_produced) as total_units_produced
from products as p
inner join production as pr 
on p.product_id = pr.product_id
group by p.category
)
select category, total_units_produced from category_totals
where total_units_produced > 30;