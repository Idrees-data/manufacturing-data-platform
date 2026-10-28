-- Manufacturing Data Platform
-- Step 1: Verify row counts in all five tables

SELECT 'machines' AS table_name, COUNT(*) AS total_rows FROM machines
UNION ALL
SELECT 'products', COUNT(*) FROM products
UNION ALL
SELECT 'production', COUNT(*) FROM production
UNION ALL
SELECT 'maintenance', COUNT(*) FROM maintenance
UNION ALL
SELECT 'quality_inspections', COUNT(*) FROM quality_inspections
ORDER BY table_name;

-- Step 2: Check data quality
-- Are there missing ids or invalid production values
select count(*) as total_records,
count(*) Filter(
where production_id is null) as missing_production_ids,
count(*) filter(
where machine_id is null) as missing_machine_id,
count(*) filter(
where product_id is null) as missing_product_id,
count(*) filter(
where shift is null) as missing_shifts,
count(*) filter(
where units_produced is null
) as missing_units_produced,
count(*) filter(
where operating_hours is null
) as missing_operating_hours
from production;

-- check duplicate product_id
select product_id, count(*) as no_of_occurance
from production
group by product_id
having count(*) > 1;

-- check for invalid values
select count(*) filter(
where units_produced < 0
) as negative_production_value,
count(*) filter(
where units_produced = 0
) as zero_production_value,
count(*) filter(
where operating_hours < 0
) as negative_operating_hours
from production;

-- Are there missing ids or invalid machines values
select count(*) total_machine_records,
count(*) filter(
where machine_id is null
) as missing_machine_id,
count(*) filter(
where machine_name is null
) as missing_machine_name,
count(*) filter(
where factory_place is null 
)as missing_location_id,
count(*) filter(
where installation_date is null
) as missing_installation_date,
count(*) filter(
where shift is null
) as missing_shift_id,
count(*) filter(
where production_line is null
) as missing_production_line,
count(*) filter(
where machine_status is null
) as missing_machine_status
from machines;

-- Are there missing ids or invalid maintenance values
select count(*) total_maintenance_records,
count(*) filter(
where maintenance_id is null
) as missing_maintenance_id,
count(*) filter(
where machine_id is null 
)as missing_machine_id,
count(*) filter(
where maintenance_type is null
) as missing_maintenance_type,
count(*) filter(
where maintenance_type is null
) as missing_maintenace_type,
count(*) filter(
where downtime_hours is null
) as missing_downtime_hours,
count(*) filter(
where maintenance_cost is null
) as missing_maintenance_cost
from maintenance;

-- Are there missing ids or invalid products values
select count(*) total_product_records,
count(*) filter(
where product_id is null
) as missing_product_id,
count(*) filter(
where product_name is null 
)as missing_product_name,
count(*) filter(
where category is null
) as missing_category_id,
count(*) filter(
where unit_cost is null
) as missing_unit_cost,
count(*) filter(
where selling_price is null
) as missing_selling_price,
count(*) filter(
where standard_production_time is null
) as missing_standard_production_time
from products;

-- Are there missing ids or invalid quality_inspections values
select count(*) as total_quality_inspection_record,
count(*) filter(
where inspection_id is null
) as missing_inspection_id,
count(*) filter(
where production_id is null
) as missing_production_id,
count(*) filter(
where inspection_date is null
) as missing_inspection_date,
count(*) filter(
where inspected_units is null
) as missing_inspected_units,
count(*) filter(
where defective_units is null
) as missing_defective_units,
count(*) filter(
where quality_status is null
) as missing_quality_status
from quality_inspections;


-- Business scenario: The factory manager wants to know which 
-- five machines produced the most units, ranked from highest to lowest.
select sum(p.units_produced) as total_units_produced_by_machine,m.machine_id, m.machine_name
from machines as m
left join production as p
on m.machine_id = p.machine_id
group by m.machine_id, m.machine_name
order by total_units_produced_by_machine desc
limit 5;

-- Business scenario: The factory manager wants to identify
-- which products have the highest total production across all machines.
select sum(p.units_produced) as total_units_produced,pp.product_id, pp.product_name
from products as pp
left join production as p
on pp.product_id = p.product_id
group by pp.product_id, pp.product_name
order by total_units_produced desc
limit 5; 


-- Project Question 3 — Production by factory location
-- Business scenario: The operations manager wants to compare production across
-- factory locations to identify which locations produce the most units.
select sum(p.units_produced) as total_units_produced,
m.factory_place
from machines as m
left join production as p
on m.machine_id = p.machine_id
group by m.factory_place
order by total_units_produced desc; 

-- Business scenario: The factory manager wants to determine 
-- which shift produces the most units.
select sum(p.units_produced) as total_units_produced,
p.shift
from production as p
group by p.shift
order by total_units_produced desc; 


-- Business scenario: The operations manager wants to understand 
-- how total production changes from day to day.
select sum(p.units_produced) as total_units_produced,
p.production_date
from production as p
group by p.production_date
order by production_date asc; 

-- Business scenario: The quality manager wants to identify
-- which products have the highest defect rates.
select p.product_id, p.product_name,sum(q.inspected_units) as total_inspected_units,
sum(q.defective_units) as total_defective_units,
    ROUND(
        (
            SUM(q.defective_units)::NUMERIC
            / NULLIF(SUM(q.inspected_units), 0)
        ) * 100,
        2) as defect_rate_percentage
from products as p
inner join production as pp
on p.product_id = pp.product_id
inner join quality_inspections as q
on pp.production_id = q.production_id
group by
p.product_id,p.product_name
order by defect_rate_percentage desc;


-- Business scenario: The quality manager wants to identify
-- which factory locations have the highest overall defect rates.

select m.factory_place,sum(q.inspected_units) as total_inspected_units,
sum(q.defective_units) as total_defective_units,
round((
sum(q.defective_units)::Numeric/Nullif(sum(q.inspected_units),0)
) * 100,2
) as defect_rate_percentage
from machines as m
inner join production as p
on m.machine_id = p.machine_id
inner join quality_inspections as q
on p.production_id = q.production_id
group by
m.factory_place
order by defect_rate_percentage desc;

-- Business scenario: The quality manager wants to understand
-- how many production inspections passed and failed.
select quality_status,count(inspection_id) as total_inspections,
sum(inspected_units) as total_inspected_units,
sum(defective_units) as total_defective_units
from quality_inspections
group by quality_status;

-- Business scenario: The quality manager wants to 
-- identify which products contribute the most defective units.
select p.product_id, p.product_name,
sum(q.defective_units) as total_defective_units
from products as p
inner join production as pp
on p.product_id = pp.product_id
inner join quality_inspections as q
on pp.production_id = q.production_id
group by p.product_id , p.product_name
order by total_defective_units desc;


-- Business scenario: The maintenance manager wants to identify
-- which machines have incurred the highest total maintenance costs.
select m.machine_id, m.machine_name, sum(mm.maintenance_cost) as total_maintenance_cost
from machines as m
inner join
maintenance as mm
on m.machine_id = mm.machine_id
group by m.machine_id, m.machine_name
order by total_maintenance_cost desc;

-- Business scenario: The operations manager wants to identify 
-- which machines have lost the most operating time due to maintenance.
select m.machine_id , m.machine_name, sum(mm.downtime_hours) as most_lost_operating_time
from machines as m
inner join maintenance as mm
on m.machine_id = mm.machine_id
group by m.machine_id,m.machine_name
order by most_lost_operating_time desc;


-- Business scenario: The maintenance manager wants to understand
-- which type of maintenance consumes the most money.
select maintenance_type, sum(maintenance_cost) as total_maintenance_cost,
sum(downtime_hours) as total_downtime_hours,
count(maintenance_id) as number_of_maintenance_events
from maintenance
group by maintenance_type;


-- Business scenario: The operations manager wants to identify 
-- which factory locations experience the most maintenance events.
select m.factory_place, count(mm.maintenance_id) as number_of_maintenance_events,
sum(mm.downtime_hours) as total_down_time
from machines as m
inner join maintenance as mm
on m.machine_id = mm.machine_id
group by m.factory_place
ORDER BY  number_of_maintenance_events desc;

-- Business scenario: The operations manager wants to
-- compare machines by their production efficiency,
-- measured as units produced per operating hour.
select m.machine_id,m.machine_name,sum(p.units_produced) as total_units_produced,
sum(p.operating_hours) as total_operating_hours,
(SUM(p.units_produced)::NUMERIC
/
NULLIF(SUM(p.operating_hours), 0) )as units_per_operating_hour
from machines as m
inner join production as p
on m.machine_id = p.machine_id
group by  m.machine_id,m.machine_name;

-- Business question: Which products have the highest profit margin per unit?
SELECT
    product_id,
    product_name,
    unit_cost,
    selling_price,
    selling_price - unit_cost AS profit_per_unit,
    ROUND(
        (
            (selling_price - unit_cost)::NUMERIC
            / NULLIF(selling_price, 0)
        ) * 100,
        2
    ) AS profit_margin_percentage
FROM products
ORDER BY profit_margin_percentage DESC NULLS LAST;


-- Business question: Which products represent the highest estimated value of production?
SELECT
    pr.product_id,
    pr.product_name,
    SUM(p.units_produced) AS total_units_produced,
    SUM(p.units_produced * pr.selling_price)
        AS estimated_production_value
FROM products AS pr
INNER JOIN production AS p
    ON pr.product_id = p.product_id
GROUP BY
    pr.product_id,
    pr.product_name
ORDER BY estimated_production_value DESC;

-- Business question: Which machines combine high production with substantial maintenance downtime?
WITH production_summary AS (
    SELECT
        machine_id,
        SUM(units_produced) AS total_units_produced,
        SUM(operating_hours) AS total_operating_hours
    FROM production
    GROUP BY machine_id
),
maintenance_summary AS (
    SELECT
        machine_id,
        SUM(downtime_hours) AS total_downtime_hours,
        SUM(maintenance_cost) AS total_maintenance_cost
    FROM maintenance
    GROUP BY machine_id
)
SELECT
    m.machine_id,
    m.machine_name,
    COALESCE(ps.total_units_produced, 0) AS total_units_produced,
    COALESCE(ps.total_operating_hours, 0) AS total_operating_hours,
    COALESCE(ms.total_downtime_hours, 0) AS total_downtime_hours,
    COALESCE(ms.total_maintenance_cost, 0) AS total_maintenance_cost
FROM machines AS m
LEFT JOIN production_summary AS ps
    ON m.machine_id = ps.machine_id
LEFT JOIN maintenance_summary AS ms
    ON m.machine_id = ms.machine_id
ORDER BY total_downtime_hours DESC;


-- Business question: Where does each factory location rank in total production?
WITH location_production AS (
    SELECT
        m.factory_place,
        SUM(p.units_produced) AS total_units_produced
    FROM machines AS m
    INNER JOIN production AS p
        ON m.machine_id = p.machine_id
    GROUP BY m.factory_place
)
SELECT
    factory_place,
    total_units_produced,
    RANK() OVER (
        ORDER BY total_units_produced DESC
    ) AS production_rank
FROM location_production
ORDER BY production_rank;


-- Business question: Which products have the highest defect rates, and what is each product's rank?
WITH product_quality AS (
    SELECT
        pr.product_id,
        pr.product_name,
        SUM(q.inspected_units) AS total_inspected_units,
        SUM(q.defective_units) AS total_defective_units,
        ROUND(
            (
                SUM(q.defective_units)::NUMERIC
                / NULLIF(SUM(q.inspected_units), 0)
            ) * 100,
            2
        ) AS defect_rate_percentage
    FROM products AS pr
    INNER JOIN production AS p
        ON pr.product_id = p.product_id
    INNER JOIN quality_inspections AS q
        ON p.production_id = q.production_id
    GROUP BY
        pr.product_id,
        pr.product_name
)
SELECT
    product_id,
    product_name,
    total_inspected_units,
    total_defective_units,
    defect_rate_percentage,
    DENSE_RANK() OVER (
        ORDER BY defect_rate_percentage DESC NULLS LAST
    ) AS defect_rate_rank
FROM product_quality
ORDER BY defect_rate_rank, product_id;


-- Business question: Are there production records with missing machine references, 
-- missing product references, negative quantities, or invalid operating hours?
SELECT
    COUNT(*) AS total_production_records,

    COUNT(*) FILTER (
        WHERE machine_id IS NULL
    ) AS missing_machine_ids,

    COUNT(*) FILTER (
        WHERE product_id IS NULL
    ) AS missing_product_ids,

    COUNT(*) FILTER (
        WHERE units_produced IS NULLd
    ) AS missing_production_quantities,

    COUNT(*) FILTER (
        WHERE units_produced < 0
    ) AS negative_production_quantities,

    COUNT(*) FILTER (
        WHERE operating_hours IS NULL
    ) AS missing_operating_hours,

    COUNT(*) FILTER (
        WHERE operating_hours < 0
    ) AS negative_operating_hours
FROM production;