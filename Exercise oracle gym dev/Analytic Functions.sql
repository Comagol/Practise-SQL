drop table bricks cascade constraints;
create table bricks (
  brick_id integer,
  colour   varchar2(10),
  shape    varchar2(10),
  weight   integer
);

insert into bricks values ( 1, 'blue', 'cube', 1 );
insert into bricks values ( 2, 'blue', 'pyramid', 2 );
insert into bricks values ( 3, 'red', 'cube', 1 );
insert into bricks values ( 4, 'red', 'cube', 2 );
insert into bricks values ( 5, 'red', 'pyramid', 3 );
insert into bricks values ( 6, 'green', 'pyramid', 1 );

commit;

SELECT count(*) FROM bricks;

--the over clause return all the rows in these case from bricks with the value of the count in each row
SELECT COUNT(*) OVER () FROM bricks;

-- here you can see all the values that is not posible using group by 
SELECT b.*,
    COUNT (*) OVER () total_count
FROM bricks b;

-- Partition by
SELECT colour, count(*), sum(weight)
FROM bricks
GROUP BY colour;

SELECT b.*,
    COUNT (*) OVER (
        PARTITION BY colour
    ) bricks_by_colour,
    SUM ( weight ) OVER (
        PARTITION BY colour
    ) weight_by_colour
FROM bricks b;


--Complete the following query to return the count and average weight of bricks for each shape:

select b.*,
       count(*) over (
         partition by shape
       ) bricks_per_shape,
       median ( weight ) over (
         partition by shape
       ) median_weight_per_shape
from   bricks b
order  by shape, weight, brick_id;

--Order By
SELECT b.*,
       COUNT(*) OVER (
        ORDER BY brick_id
       ) running_total,
       SUM (weight) OVER (
        ORDER BY brick_id
       ) running_weight
FROM bricks b;

--second exercise
--Complete the following query to get the running average weight, ordered by brick_id:

select b.brick_id, b.weight,
       round ( avg ( weight ) over (
         order by brick_id
       ), 2 ) running_average_weight
from   bricks b
order  by brick_id;

