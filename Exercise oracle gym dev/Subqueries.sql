select * from BRICKS;

select * from COLOURS;

SELECT * FROM (
    select * from BRICKS
);

select * from (
    select colour, count(*) qty
    from BRICKS
    group by colour
) brick_count;

select * from (
    select colour, count(*) c
    from bricks
    group by colour
) brick_counts
right join COLOURS
on    brick_counts.colour = COLOURS.colour_name
where nvl ( brick_counts.c, 0) < colours.minimum_bricks_needed;


select * from (
  select colour, count (*) c,
  min(BRICK_ID),
  max(brick_id)
  from bricks
  group by colour
) bricks_count;

SELECT * FROM colours c
WHERE c.colour_name IN (
    SELECT b.colour FROM bricks b
);

SELECT * FROM colours c
WHERE EXISTS (
    SELECT null FROM BRICKS b
    where b.colour = c.colour_name
);

select * from colours c
where  c.colour_name in (
  select b.colour from bricks b
  where  b.brick_id < 5
);

SELECT * FROM colours c
WHERE EXISTS (
    select null from bricks
);

SELECT * FROM colours c
WHERE NOT EXISTS (
    SELECT NULL FROM bricks b
    WHERE b.colour = c.COLOUR_NAME
);

select * from colours c
where  c.colour_name not in (
  select b.colour from bricks b
  where b.colour is not null
);

SELECT * FROM bricks b
WHERE b.colour in (
    select c.colour_name from colours c
    WHERE c.minimum_bricks_needed = 2
);

select colour_name, (
    select count(*)
    from bricks b
    where b.colour = c.colour_name
    group by b.colour
    ) brick_counts
from colours c;

select colour_name, nvl ( (
    select count(*)
    from bricks b
    where b.colour = c.colour_name
    group by b.colour
    ), 0 ) brick_counts
from colours c;

select c.colour_name, (
    select count (*)
    from bricks b
    group by colour
) bricks_counts
from colours c;

select colour, count(*) c
from bricks b
group by colour
having count (*) < (
    select c.minimum_bricks_needed
    from colours c 
    where c.colour_name = b.colour
);

select c.colour_name, (
    select min (b.brick_id) 
    from bricks b
    where c.colour_name = b.colour
    )min_brick_id
from colours c 
where c.colour_name is not null;

with bricks_colour_counts as (
    select colour, count(*)
    from bricks
    group by colour
)
select * from bricks_colour_counts;

SELECT c.colour_name,
       c.minimum_bricks_needed, (
        SELECT AVG ( COUNT (*) )
        FROM bricks b
        GROUP BY b.colour
       )mean_bricks_per_colour
FROM colours c
WHERE c.minimum_bricks_needed < (
    SELECT COUNT(*)
    FROM bricks b
    where b.colour = c.colour_name
    GROUP BY b.colour
);

with brick_count as (
    select b.colour, count (*) c
    from bricks b
    group by b.colour
)
select c.colour_name,
       c.minimum_bricks_needed, (
        select avg (bc.c)
        from brick_count bc
       )mean_bricks_per_colour
from colours c 
where c.minimum_bricks_needed < (
    select bc.c
    from brick_count bc
    where bc.colour = c.colour_name
);

with brick_count as (
    --1.first cte
    select b.colour, count (*) c
    from bricks b
    group by b.colour
), average_bricks_per_colour as (
    --2.second cte
    select avg (c) average_count
    from brick_count
)
select * from brick_count bc
join average_bricks_per_colour ac 
--return those rows where the value in step one is less than in step two
on bc.c < average_count;

with colour_count as (
  select COUNT(*)
  from colours
)
select * from colour_count;