-- show the machine name product name and 
-- total units produced for each product made by each machine.
select m.machine_name, p.product_name, sum(pp.units_produced) as total_units_produced
from machines as m
inner join production as pp
on m.machine_id = pp.machine_id
inner join products as p
on pp.product_id = p.product_id
group by m.machine_name, p.product_name;

-- find the total units produced for each product category
select sum(pp.units_produced) as total_units_produced,
		p.category
from products as p
left join production as pp
on pp.product_id = p.product_id
group by p.category;

-- Find the 5 machines by total_units_produced.
-- show the machine_name,total_units, form highest to lowest
select m.machine_name,sum(pp.units_produced) as total_units_produced
from machines as m
left join production as pp
on
m.machine_id = pp.machine_id
group by machine_name
order by sum(pp.units_produced)
limit 5;

-- find the total maintenanace cost for each machine,
-- showing the machine name and total maintenace cost, sorted from highest to lowest
select sum(m.maintenance_cost) as total_maintenance_cost,mm.machine_name
from maintenance as m
left join machines as mm
on m.machine_id = mm.machine_id
group by machine_name
order by sum(m.maintenance_cost) desc;

-- Find the total defective units for each machine
-- show only machines with more than 5 defective units, 
-- sorted from highest to lowest
select m.machine_id,m.machine_name, sum(q.defective_units) as total_defective_units
from machines as m
inner join production as p
on m.machine_id = p.machine_id
inner join quality_inspections as q
on p.production_id = q.production_id
group by m.machine_id , m.machine_name
having sum(q.defective_units) >5
order by total_defective_units des   c;
