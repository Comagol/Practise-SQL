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
  from   dual;

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

when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
*/

merge into purchased_bricks pb
using ( 
  select 'blue' colour, 'cube' shape, 15.95 price 
  from   dual 
) bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
when matched then
  update set pb.price = bfs.price;

select * from purchased_bricks;

--MERGING TWO TABLES
--you may also want to upsert two whole tables, so all the rows in the cource have a matching row un the target
-- you can do this by writing an update-if-wxists. followed by an insert-not-exists (or vice versa) like

update purchased_bricks pb
set    pb.price = (
  select bfs.price
  from   bricks_for_sale bfs
  where  pb.colour = bfs.colour 
  and    pb.shape = bfs.shape
)
where  exists (
  select null
  from   bricks_for_sale bfs
  where  pb.colour = bfs.colour 
  and    pb.shape = bfs.shape
);

insert into purchased_bricks (colour, shape, price)
  select bfs.colour, bfs.shape, bfs.price
  from   bricks_for_sale bfs
  where  not exists (
    select null
    from   purchased_bricks pb
    where  pb.colour = bfs.colour
    and    pb.shape = bfs.shape
  );

select * from purchased_bricks;

rollback;

/*
But, as with upserting a single row, this a lot of typing and hard to follow. You can simplify the above into the following merge:
*/

merge into purchased_bricks pb
using bricks_for_sale bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then 
    insert ( pb.colour, pb.shape, pb.price )
    values ( bfs.colour, bfs.shape, bfs.price )
when matched then 
    update set pb.price = bfs.price;

select * from purchased_bricks;

commit;

/*
These allows you to keep target rows in sync with those in the source. but this only affects rows with a match in the source.

For example, if you:

Set the price of all bricks_for_sale to 0.99
Add a red pyramid to bricks_for_sale
Add a green cube to purchased_bricks

Merge adds the red pyramid. But it will only change the price of the red cube and blue bricks. The green cube has no matching row in bricks_for_sale. So its price stays the same
*/
update bricks_for_sale
set    price = 0.99;

insert into bricks_for_sale values ( 'red', 'pyramid', 5.99 );
insert into purchased_bricks values ( 'green', 'cube', 9.95 );

merge into purchased_bricks pb
using bricks_for_sale bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
when matched then
  update set pb.price = bfs.price;

select * from purchased_bricks;

rollback;


--EXERCISE
--complete the following merge. It should add the yellow cube to purchased_bricks. 
-- And update the price of the red brick to 5.55:

merge into purchased_bricks pb
using ( 
  select 'yellow' colour, 'cube' shape, 9.99 price from dual 
  union all
  select 'red' colour, 'cube' shape, 5.55 price from dual 
) bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
when matched then
  update set pb.price = bfs.price;

select * from purchased_bricks pb
order  by colour, shape;

rollback;

--MERGE RESTICTIONS
--you can only update columns not in the join clause and just update each row once.

--UPDATING JOIN COLUMNS
--if you try to set columns in the join clause, you will get an error. For example, the following fails.
--because it tries to update colour and shape that are in the join clause.
merge into purchased_bricks pb
using bricks_for_sale bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
    insert ( pb.colour, pb.shape, pb.price )
    values ( bfs.colour, bfs.shape, bfs.price )
when matched then
    update set pb.colour = bfs.colour, pb.shape = bfs.shape;


--UPDATE EACH ROW ONCE
-- the join shouls map each row in the source to at most one in the target. if there are two or more rows in the source
-- which map to a row in the target, you'll get an error.ALTER

merge into purchased_bricks pb
using bricks_for_sale bfs
on    ( pb.colour = bfs.colour )
when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
when matched then
  update set pb.price = bfs.price;

--CONDITIONAL MERGING
/*
when merging tables, you may want to preserve values for some of the target'sexisting rows. Or stop users inserting
certain new values.

you can do both using a where clause in the matched clauses. this like a regular were clause and comes after the insert or update

insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
  where  bfs.colour = 'blue'


the folowwing code updated the price of all the bricks for sale to 100 and adds red pyramid. but the merge includes a 
filter to only affect blue rows in both clauses. so the price of the red remaINS 4.95 and the red pyramid is not added
to the purchased_bricks
*/

update bricks_for_sale
set    price = 100;

insert into bricks_for_sale values ( 'red', 'pyramid', 5.99);

merge into purchased_bricks pb
using bricks_for_sale bfs 
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then 
    insert ( pb.colour, pb.shape, pb.price )
    values ( bfs.colour, bfs.shape, bfs.price)
    where bfs.colour = 'blue'
when matched then 
    update set pb.price = bfs.price
    where bfs.colour = 'blue';

select * from purchased_bricks;
rollback;


--EXERCISE
--Complete the following merge statement, so it removes matched rows from purchased_bricks that have a price less than 9:
/*
bad practise
delete purchased_bricks;

insert into purchased_bricks values ( 'blue', 'pyramid', 9.99 );
insert into purchased_bricks values ( 'red', 'cube', 100 );
insert into purchased_bricks values ( 'blue', 'cube', 100 );


select * from purchased_bricks;
select * from bricks_for_sale;

merge into purchased_bricks pb
using bricks_for_sale bfs
on    ( pb.colour = bfs.colour and pb.shape = bfs.shape )
when not matched then
  insert ( pb.colour, pb.shape, pb.price )
  values ( bfs.colour, bfs.shape, bfs.price )
when matched then
  update set pb.price = bfs.price
  delete where pb.price < 9;

select * from purchased_bricks;

rollback;

*/