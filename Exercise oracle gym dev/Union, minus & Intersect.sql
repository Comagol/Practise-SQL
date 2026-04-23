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





