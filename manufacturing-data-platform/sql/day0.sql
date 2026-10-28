-- Display each production record alongside its machine factory location.
-- production_id, machine_id, units_produced, factory_place

select p.production_id, p.machine_id, p.units_produced, m.factory_place
from production as p
inner join machines as m
on p.machine_id = m.machine_id;

-- Show each production record with the machine's name and factory location.
select  p.units_produced, m.machine_name, m.factory_place
from production as p
inner join machines as m
on p.machine_id = m.machine_id;

-- Find all machines, including machines that have never produced anything.
select m.machine_id, p.production_id,p.units_produced
from production as p
Left join machines as m
on p.machine_id = m.machine_id
where p.units_produced is Null ;

-- Find all machines and their total units produced, 
-- including machines with no production records.
select m.machine_id , coalesce(sum(p.units_produced)) as total_units
from machines as m
left join production as p
on m.machine_id = p.machine_id
group by m.machine_id
order by total_units desc;

-- Modify the query to show only machines 
-- whose total production is greater than 20 units.
select m.machine_id, coalesce(sum(p.units_produced)) as total_units
from machines as m
left join production as p
on m.machine_id = p.machine_id
group by m.machine_id
having coalesce(sum(p.units_produced)) > 20
order by total_units desc;


-- Find each machine's name, its factory location, and its total units produced, 
-- including machines with no production records.
select m.machine_name, m.machine_id, m.factory_place, 
sum(p.units_produced) as total_units_produced
from machines as m
left join production as p
on m.machine_id = p.machine_id
WHERE p.production_id IS NULL
group by m.machine_id,
m.machine_name,
m.factory_place;

-- Write a query to find each machine's average units produced per production record,
-- including machines with no production records.
SELECT
    m.machine_id,
    COALESCE(AVG(p.units_produced), 0) AS avg_units
FROM machines AS m
LEFT JOIN production AS p
    ON m.machine_id = p.machine_id
GROUP BY m.machine_id
ORDER BY avg_units DESC;
