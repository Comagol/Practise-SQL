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

--Partition By + Order By
SELECT b.*,
    COUNT (*) OVER (
        PARTITION BY colour
        ORDER BY brick_id
    ) running_total,
    SUM (weight) OVER (
        PARTITION BY colour
        ORDER BY brick_id
    ) running_weight
FROM bricks b;

--Windowing Clause
--these is not what we want (need to know why?)
SELECT b.*,
    COUNT (*) OVER (
        ORDER BY weight
    ) running_total,
    SUM ( weight ) OVER (
        ORDER BY weight
    ) running_weight
FROM bricks b;


--using windowing clause
SELECT B.*,
    COUNT (*) OVER (
        ORDER BY weight
        ROWS BETWEEN unbounded preceding and current ROW
    ) running_total,
    SUM ( weight ) OVER (
        ORDER BY weight
        ROWS BETWEEN unbounded preceding and current ROW
    ) running_weight
FROM bricks b
ORDER BY weight;


--Sliding Windows
SELECT b.*,
    SUM ( weight ) OVER (
        ORDER BY weight 
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) running_row_weight,
    SUM ( weight ) OVER (
        ORDER BY weight
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) running_value_weight,
    SUM ( weight ) OVER (
        ORDER BY weight
        GROUPS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) running_group_weight
FROM bricks b
ORDER BY weight, brick_id;



SELECT b.*,
    SUM (weight) OVER (
        ORDER BY weight
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) sliding_row_window,
    SUM (weight) OVER (
        ORDER BY weight
        RANGE BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) sliding_value_window,
    SUM (weight) OVER (
        ORDER BY weight
        GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) sliding_group_window
FROM bricks b
ORDER BY weight;


SELECT b.*,
    COUNT (*) OVER (
        ORDER BY weight
        RANGE BETWEEN 2 PRECEDING AND 1 PRECEDING
    )count_weight_2_lower_than_current,
    COUNT (*) OVER (
        ORDER BY weight
        RANGE BETWEEN 1 FOLLOWING AND 2 FOLLOWING
    ) count_weight_2_greater_than_current
FROM bricks b
ORDER BY weight;

--exercise but not quite sure abaout these knoledge (look up for more info)
--The minimum colour of the two rows before (but not including) the current row
--The count of rows with the same weight as the current and one value following


select b.*,
       min ( colour ) over (
         order by brick_id
         rows BETWEEN 2 PRECEDING AND 1 PRECEDING
       ) first_colour_two_prev,
       count (*) over (
         order by weight
         range BETWEEN CURRENT ROW AND 1 FOLLOWING
       ) count_values_this_and_next
from   bricks b
order  by weight;


--FILTERING ANALYTIC FUNCTIONS

SELECT colour FROM bricks
GROUP BY colour
HAVING COUNT(*) >=2;
