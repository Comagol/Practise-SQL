drop table bricks_for_sale cascade constraints;
drop table purchased_bricks cascade constraints;
create table bricks_for_sale (
  colour   varchar2(10),
  shape    varchar2(10),
  price    number(10, 2),
  primary key ( colour, shape )
);

create table purchased_bricks (
  colour   varchar2(10),
  shape    varchar2(10),
  price    number(10, 2),
  primary key ( colour, shape )
);

insert into bricks_for_sale values ( 'red', 'cube', 4.95 );
insert into bricks_for_sale values ( 'blue', 'cube', 7.75 );
insert into bricks_for_sale values ( 'blue', 'pyramid', 9.99 );

commit;


--INTRODUCTION
--purchased bricks is empty
select * from purchased_bricks;

select * from bricks_for_Sale;

--INSERT-THEN-UPDATE OR UPDATE-THEN-INSERT
/* When adding rows to a table, sometimes you want to do a insert-if-not-exists, update-if-not-exists. as knowns as (AKA) an upsert
writing this as separate insert and update statements is cumbersome
*/

declare
  l_colour varchar2(10) := 'blue';
  l_shape  varchar2(10) := 'pyramid';
  l_price  number(10, 2) := 9.99;
begin

  update purchased_bricks pb
  set    pb.price = l_price
  where  pb.colour = l_colour
  and    pb.shape = l_shape;

  if sql%rowcount = 0 then
    insert into purchased_bricks
    values ( l_colour, l_shape, l_price );
  end if;
end;
/

select * from purchased_bricks;

/*

Purchased_bricks was empty before this code. So the update was wasted effort. 
It would have been better to do the insert first.

You can do this by flipping the statements around. 
And, instead of checking if the sql%rowcount is zero, trapping a unique key violation:
*/


declare
  l_colour varchar2(10) := 'blue';
  l_shape  varchar2(10) := 'pyramid';
  l_price  number(10, 2) := 15.49;
begin

  insert into purchased_bricks
  values ( l_colour, l_shape, l_price );

exception
  when DUP_VAL_ON_INDEX then
    update purchased_bricks pb
    set    pb.price = l_price
    where  pb.colour = l_colour
    and    pb.shape = l_shape;
end;
/

select * from purchased_bricks;

commit;


/*
But the code above "added" the same brick! 
You needed to update its price. So the insert was a waste here.

When writing upserts, in general it's hard to know whether insert or update is most likely. 
You can spend a lot of effort figuring this out. Luckily there's a better way: Merge!
*/

--MERGE NEW VALUES
-- merge is a new statement that allows us to do either an inser or an update as needed. To use it you need to state how values in the target table
-- realte to those in the source in the join clause. Then add rows un the when not matched clause. And updete them using when matched.

-- The target table is the one that you'll add or change the rows of. You merge the source data into this.

-- The source has to be a table. But a query returns a table. So you can select the values you want to upsert. so you can merge a blue cube costing 15.95

select 'blue' colour, 'cube' shape, 15.95 price 
  from   dual

-- you need to link these values to rows in the target. Each source row should each link to at most one row in the target table.
-- the orimary key of purchased_bricks is colour and shape. so you can garantee by joining using these columns.
-- on ( pb.colour = bfs.colour and pb.shape = bfs.shape)

-- You then define what to add or change in merge's matched clauses.

-- WHEN MATCHED 
-- this clauses fires for each row in the cource that links to a row in the target. so if there is a blue cube in the targer table, you cna chage its price here like so:
/*
when matched then
  update set pb.price = bfs.price;
*/

--WHEN NOT MATCHED
/*
for each row in the source that doesn't match one in the target, the when not matched clause fires. here you state the values you'd 
like to insert into the target for which columns. if the source and target tables have the same column names, you must alias the columns in the value clause
*/









