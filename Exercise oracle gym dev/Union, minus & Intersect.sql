create table my_brick_collection (
colour varchar2(10),
shape  varchar2(10),
weight integer
);

drop table your_brick_collation cascade constraints;
create table your_brick_collection (
  height integer,
  width  integer,
  depth  integer,
  colour varchar2(10),
  shape  varchar2(10)
);

insert into my_brick_collection values ( 'red', 'cube', 10 );
insert into my_brick_collection values ( 'blue', 'cuboid', 8 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( 'green', 'pyramid', 20 );
insert into my_brick_collection values ( null, 'cuboid', 20 );

insert into your_brick_collection values ( 2, 2, 2, 'red', 'cube' );
insert into your_brick_collection values ( 2, 2, 2, 'blue', 'cube' );
insert into your_brick_collection values ( 2, 2, 8, null, 'cuboid' );

commit;

SELECT * FROM my_brick_collection;


SELECT * FROM your_brick_collection;

--The set operator Union, intersect and minus allows us to combine many tables into one

--UNION
-- these operator combine many table into one
--To use it the tables must have the same number of columns with matching data types in both positions

--in these example it will throws an error (*). Because the table has mismatches in their columns
SELECT * FROM MY_BRICK_COLLECTION
UNION
SELECT * FROM YOUR_BRICK_COLLECTION;


--but if we use the colour and shape colum we can use the operator
SELECT colour, shape FROM my_brick_collection
UNION
SELECT colour, shape FROM your_brick_collection;

-- DISTINCT
-- UNION APPLIIES THE DISTINCT OPERATOR TO THE RESULTS. THIS DISCARDS DUPLICATED ROWS
-- DISTINCT GOES RIGTH AFTER THE SELECT CLAUSE

select distinct * from my_brick_collection;

--also works for specific columns
SELECT DISTINCT shape FROM my_brick_collection;

-- UNION ALL

--TO SEE ALL THE ROWS OF AN UNION (INCLUDING DUPLICATED VALUES) NOT THE LIST OF DISTINCTS

SELECT colour, shape FROM my_brick_collection
UNION ALL 
SELECT colour, shape FROM your_brick_collection;

-- A standar union is the same as these
SELECT DISTINCT * FROM (
    SELECT colour, shape FROM my_brick_collection
    UNION ALL
    SELECT colour, shape FROM your_brick_collection
);

-- EXERCISE 1
-- Complete this query to return a list of all the colours in the two tables. Each colour must only appear once:

select colour from my_brick_collection
UNION
select colour from your_brick_collection
order by colour;

-- EXERCISE 1.1
--Complete the following query to return a list of all the shapes in both tables. There must show one row for each row in the source tables:

select shape from my_brick_collection
UNION ALL
select shape from your_brick_collection
order  by shape;

-- SET DIFERENCE
-- THESE OPERATOR RETURNS ALL THE ROWS THAT ARE IN A TABLE THAT ARE NOT IN THE OTHER TABLE

SELECT colour, shape FROM your_brick_collection ybc
WHERE NOT EXISTS (
    SELECT NULL FROM my_brick_collection mbc
    WHERE ybc.colour = mbc.colour
    AND ybc.shape = mbc.shape
);


--when the query is bigger these is tricky to undestand
-- but the real issue is to handle the null values
-- to fix these the test is that the column are equals or both are null

select colour, shape from your_brick_collection ybc
where  not exists (
  select null from my_brick_collection mbc
  where  ( ybc.colour = mbc.colour or
    ( ybc.colour is null and mbc.colour is null )
  )
  and    ( ybc.shape = mbc.shape or
    ( ybc.shape is null and mbc.shape is null )
  )
);


-- MINUS
--OPERATOR THAT IMPLEMENTS SET DIFERENCE 
-- THE NULL VALUES ARE CONSIDERED EQUALS.

SELECT colour, shape FROM YOUR_BRICK_COLLECTION
MINUS
SELECT colour, shape FROM MY_BRICK_COLLECTION;

--LIKE UNION, MINUS APPLIES A DISTINCT TO THE OUTPUT

select colour, shape from my_brick_collection
minus
select colour, shape from your_brick_collection;

-- BUT IF WE ADD ALL TO MINUS 
SELECT colour, shape FROM MY_BRICK_COLLECTION
MINUS ALL
SELECT colour, shape FROM YOUR_BRICK_COLLECTION;

--YOU CAN USE NOT EXISTS TO FIND ALL ROWS IN ONE TABLE NOT IN THE OTHER
SELECT colour, shape FROM MY_BRICK_COLLECTION mbc
WHERE NOT EXISTS (
    SELECT NULL FROM YOUR_BRICK_COLLECTION ybc 
    WHERE ( ybc.colour = mbc.colour OR (ybc.colour IS NULL AND mbc.colour IS NULL))
    AND    ybc.shape = mbc.shape
);

--NEW EXCEPT METHOD
SELECT colour, shape FROM MY_BRICK_COLLECTION
EXCEPT ALL
SELECT colour, shape FROM YOUR_BRICK_COLLECTION;

--FINDING COMMUN VALUES
SELECT colour, shape FROM YOUR_BRICK_COLLECTION ybc
WHERE EXISTS (
    SELECT NULL FROM MY_BRICK_COLLECTION mbc 
    WHERE ( ybc.colour = mbc.colour OR (ybc.colour IS NULL AND mbc.colour IS NULL ) )
    AND ybc.shape = mbc.SHAPE
);

-- INTERSECT

--these operator find common values
SELECT colour, shape FROM YOUR_BRICK_COLLECTION
INTERSECT
SELECT colour, shape FROM MY_BRICK_COLLECTION;

-- EXERCISE
-- COMPLETE THE FOLLOWING QUERY TO RETURN A LIST OF ALL THE SHAPES IN MY COLLECTION NOT IN YOURS

select shape from my_brick_collection
MINUS 
select shape from your_brick_collection;

--Complete the following query to return a list of all the colours that are in both tables:

select colour from my_brick_collection
INTERSECT
select colour from your_brick_collection
order  by colour;

--Finding THE DIFERENCE BETWEEN TWO TABLES
-- SIMETRIC DIFERENCE = comparing two tables returning a list of all the values that only exist in one table
-- there is no native operator but i can do it by

--Finding the rows in table one not in table two with minus
--Finding the rows in table two not in table one with minus
--Combining the output of these two operations with union (all)

SELECT colour, shape FROM YOUR_BRICK_COLLECTION
MINUS
SELECT colour, shape FROM MY_BRICK_COLLECTION
UNION ALL 
SELECT colour, shape FROM MY_BRICK_COLLECTION
MINUS
SELECT colour, shape FROM YOUR_BRICK_COLLECTION;

--SO TO FIX THESE I HAVE TO USE ()

SELECT * FROM (
    SELECT colour, shape FROM YOUR_BRICK_COLLECTION
    MINUS
    SELECT colour, shape FROM MY_BRICK_COLLECTION
    ) UNION ALL ( 
    SELECT colour, shape FROM MY_BRICK_COLLECTION
    MINUS
    SELECT colour, shape FROM YOUR_BRICK_COLLECTION
);

-- OR DO IT THESE OTHER WAY BUT ALSO WITH ()

select * from (
  select colour, shape from your_brick_collection
  union all
  select colour, shape from my_brick_collection
) minus (
  select colour, shape from my_brick_collection
  intersect
  select colour, shape from your_brick_collection
);

--Symmetric difference with Group By


insert into your_brick_collection values ( 4, 4, 4, 'red', 'cube' );

select * from (
  select colour, shape from your_brick_collection
  minus
  select colour, shape from my_brick_collection
) union all (
  select colour, shape from my_brick_collection
  minus
  select colour, shape from your_brick_collection
);



select colour, shape, sum ( your_bricks ), sum ( my_bricks )
from (
  select colour, shape, 1 your_bricks, 0 my_bricks
  from   your_brick_collection
  union all
  select colour, shape, 0 your_bricks, 1 my_bricks
  from   my_brick_collection
)
group  by colour, shape
having sum ( your_bricks ) <> sum ( my_bricks );


select colour, shape,
       case
         when sum ( your_bricks ) < sum ( my_bricks ) then 'ME'
         when sum ( your_bricks ) > sum ( my_bricks ) then 'YOU'
         else 'EQUAL'
       end who_has_extra,
       abs ( sum ( your_bricks ) - sum ( my_bricks ) ) how_many
from (
  select colour, shape, 1 your_bricks, 0 my_bricks
  from   your_brick_collection
  union all
  select colour, shape, 0 your_bricks, 1 my_bricks
  from   my_brick_collection
)
group  by colour, shape;