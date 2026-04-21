drop table toys cascade constraints;
create table toys (
  toy_name       varchar2(30),
  weight         integer,
  price          number(5,2),
  purchased_date date,
  last_lost_date date
);

insert into toys values ('Miss Snuggles', 4,  9.99,  date'2018-02-01', date'2018-06-01');
insert into toys values ('Baby Turtle',   1,  5.00,  date'2016-09-01', date'2017-03-03');
insert into toys values ('Kangaroo',      10, 29.99, date'2017-03-01', date'2018-06-01');
insert into toys values ('Blue Dinosaur', 8,  9.99,  date'2013-07-01', date'2016-11-01');
insert into toys values ('Purple Ninja',  8,  29.99, date'2018-02-01', null);

commit;

select * from toys;

select * FROM toys
ORDER BY price;

SELECT * FROM toys
ORDER BY purchased_date;

SELECT * FROM toys
ORDER BY toy_name;

SELECT * FROM toys
ORDER BY price desc;

SELECT toy_name, price 
FROM toys
ORDER BY price, toy_name;


--exercise
SELECT toy_name, weight, purchased_date
FROM toys
ORDER BY weight, purchased_date desc;


--sorting nulls
SELECT * FROM TOYS
ORDER BY last_lost_date;

SELECT * FROM TOYS
ORDER BY last_lost_date NULLS FIRST;

-- second exercise
--Complete the query to sort the rows by:

--Price, cheapest to most expensive
--Toys with same price by date last lost, from newest to oldest. Rows with a null last_lost_date should appear above any of the same price
SELECT toy_name, price, last_lost_date
FROM toys
ORDER BY price, last_lost_date DESC nulls first;

SELECT * FROM toys
ORDER BY CASE 
    WHEN toy_name = 'Miss Snuggles' THEN 1
    ELSE 2
END , toy_name;

--Positional notation also using alias (you can us as or not)

SELECT t.*,
       CASE 
            WHEN toy_name = 'Miss Snuggles' THEN 1
            ELSE 2
        END as case_sentence
FROM toys t
ORDER BY 6,1;


SELECT t.*,
    CASE
        WHEN toy_name = 'Miss Snuggles' THEN 1
        ELSE 2
    END custom_sort
FROM toys t
ORDER BY custom_sort, toy_name;

--third exercise
--Kangaroo is top
--blue Dinosaur is second
--the remaining toys are ordered by price, cheapest to most expensive.

SELECT t.toy_name, t.price,
    CASE 
        WHEN toy_name = 'Kangaroo' then 1
        WHEN toy_name = 'Blue Dinosaur' then 2
        ELSE 3
    END custom_sort
FROM toys t
order by custom_sort, price;

--NOT SURE IF THE OUTPUT OF THE QUERY IS CORRECT (BECAUSE I SEE CUSTOM_SORT AND IN THE EXAMPLE THE CUSTON SORT IS NOT IN THE EXAMPLE)

SELECT * 
FROM toys
WHERE rownum<=3
ORDER BY price DESC;

SELECT * FROM (
    SELECT *
    FROM toys
    ORDER BY price DESC
)
WHERE ROWNUM <=3;

--TOP N QUERY
SELECT * FROM (
    SELECT t.*, row_number() OVER (ORDER BY price DESC) rn
    FROM toys t
)
where rn <=3
order by rn;

--easier way to di it with fetch first x rows only

SELECT * FROM toys
ORDER BY price DESC
FETCH FIRST 3 ROWS ONLY;

-- TOP-N WITH TIES
-- THESE MEANS THAT IF YOU HAVE TWO TOYS WITH THE SAME PRICE AND YOU USE TIES YOU GET BOTH OF THE TOYS AND NOT ONLY ONE OF THEM RANDOM
--IN THESE CASE I HAVE 4 ROWS BECAUSE THERE ARE 2 TOYS 9.99 AND TWO AT 29.99 so it return 4 values
SELECT toy_name, price FROM toys
ORDER BY price DESC
FETCH FIRST 3 ROWS WITH TIES;

SELECT * FROM (
    SELECT t.*,
        RANK() OVER ( ORDER BY price DESC) rn
    FROM toys t
)
WHERE rn <= 3
order by rn;

SELECT * FROM (
    SELECT t.*,
        DENSE_RANK() OVER ( ORDER BY price DESC) rn
    FROM toys t
)
WHERE rn <= 3
order by rn;


select * from toys
order by price, purchased_date
fetch first 9 partition by price, 1 row only;

--LAST EXERCISE
SELECT toy_name
FROM toys
ORDER BY toy_name
FETCH FIRST 3 ROWS ONLY;