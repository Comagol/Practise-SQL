select * from employees;

--Connect By
-- I s an oracle specific way to create data trees using sql. 
-- It has two key clauses, start with and connect by

--here i state which rows are the roots (the rows that apears at the top)
--START WITH employee_id = 100
-- in a company we can use these
-- START WITH manager_id is null

-- Connect by
-- Here is where i can state the parent child relationship. This links the columns that store te panrent and child values
-- CONNECT BY PRIOR employee_id = manager_id

SELECT * FROM employees
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- FIRST EXERCISE
--Complete the following query to build a "reverse" org chart. 
--Begin with employee 107 and go up the chain to Steven King. 
--This switches the parent-child relationship so the employee is the parent row for their manager.

select employee_id, first_name, last_name, manager_id
from   employees e
start  with employee_id IN (select e.EMPLOYEE_ID from employees e
where not exists(
        select employee_id from employees emp
        where e.employee_id = emp.manager_id
    ))
connect by employee_id = PRIOR manager_id;

--RECURSIVE WITH
-- these has two querys a base query and a recursive one


-- BASE QUERY
-- WE USE THESE TO DEFINE THE ROOT ROWS IN THE TREE. THIS IS LIKE THE START WITH CLAUSE IN A CONNECT BY.

SELECT employee_id, first_name, last_name, manager_id
FROM EMPLOYEES
WHERE manager_id is null;


--RECURSIVE QUERY
-- THIS MAPS TO THE CONNECT BY CLAUSE. HERE IS WHERE THE SHOURCE TABLE JOINS TO THE WITH CLAUSE

SELECT e.employee_id, e.first_name, e.last_name, e.manager_id
FROM org_chart oc
JOIN employees e 
ON e.manager_id = oc.employee_id;

--when using recursive with you must provide aliases for al the columns in the returns
/*with org_chart (
  employee_id, first_name, last_name, manager_id
) as ( ...);*/

with org_chart (
  employee_id, first_name, last_name, manager_id
) as (
  select employee_id, first_name, last_name, manager_id 
  from   employees
  where  manager_id is null
  union  all
  select e.employee_id, e.first_name, e.last_name, e.manager_id 
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
)
  select * from org_chart;

--second exercise

with org_chart (
  employee_id, first_name, last_name, manager_id
) as (
  select employee_id, first_name, last_name, manager_id 
  from   employees
  where  employee_id = 107
  union  all
  select e.employee_id, e.first_name, e.last_name, e.manager_id 
  from   org_chart oc
  join   employees e
  on     e.employee_id = oc.manager_id
)
  select * from org_chart;

-- LEVEL
-- with te query so far is dificult to know how senior someone is in the company.
-- these returns the current depth in the tree, starting with the roots at 1.
-- each new set of children increases by 1.

-- CONNECT BY
-- With connect by you can use the pseudo column level. these return the current depth on the tree. starting with 1 for the roots.
-- Each new set of childrens


SELECT LEVEL, employee_id, first_name, last_name, manager_id
FROM EMPLOYEES
START WITH manager_id IS NULL
CONNECT BY PRIOR employee_id = manager_id;

-- This helps but it is still tricky to tell the seniority.
-- Indenting the level with lpad help more
-- lpad ( str1, N, str2 )
-- It adds the characters in str2 before those in str1 until the string is N characters long.ALTER

select level, employee_id,
       lpad ( ' ', level, ' ' ) || first_name || ' ' || last_name name, manager_id
from   employees
start  with manager_id is null
connect by prior employee_id = manager_id;


-- Recursive With
-- recursive has no equivalent of level so you need to build your own.
with org_chart (
  employee_id, first_name, last_name, manager_id, lvl
) as (
  select employee_id, first_name, last_name, manager_id, 1 lvl
  from   employees
  where  manager_id is null
  union  all
  select e.employee_id, e.first_name, e.last_name, e.manager_id, oc.lvl + 1
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
)
select * from org_chart;

--sorting output: connect By
--when you build a hirerquical query , the DB returns the rows in an order matching the tree structure
-- Connect by returns rows in a deoth-first search order. if you use a regular order by you will lose these sort
-- but you can preserve the depth-first tree and sort rows with the same parent. you do this with the sibiling clause of order by.

select level, employee_id, first_name, last_name, hire_date, manager_id 
from   employees
start  with manager_id is null
connect by prior employee_id = manager_id
order siblings by hire_date;


--SORTING OUTPUT: RECURSIVE WITH
-- allows you to choose whether you want to tranverse the tree using depth-first or bradth-first search. 

--DEPTH-FIRST-SEARCH
-- these start at the root. then picksone of the children. it then gets the child's child. And so on, down the tree accessing child nodes first
--when it hits a leaf it goes back up the tree until it finds an unvisited child.
-- so it goes as far down the tree can before accessing anather row at the same level.

-- to use these depth-first-search you have to specify it in the seach clause.
-- the columns you sort by defines which order the DB returns sibilings. and the set clasue define a new column sorting
-- this sequence. it starts with 1 and increments for each new row by 1

with org_chart (
  employee_id, first_name, last_name, hire_date, manager_id, lvl
) as (
  select employee_id, first_name, last_name, hire_date, manager_id, 1 lvl
  from   employees
  where  manager_id is null
  union  all
  select e.employee_id, e.first_name, e.last_name, e.hire_date, e.manager_id, oc.lvl + 1
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
) search depth first by hire_date set hire_seq
  select * from org_chart
  order  by hire_seq;

--BREADTH-FIRST SEARCH
--intead of traveling down the tre this search goes acroos it.
-- Again this starts with the root. but it accesses all the rows at the same level before going down to any children.
-- the sorting column define wich order you access nodes at the same depth.
-- So the following returns all the employees at the same rank next to each other.

with org_chart (
  employee_id, first_name, last_name, hire_date, manager_id, lvl
) as (
  select employee_id, first_name, last_name, hire_date, manager_id, 1 lvl
  from   employees
  where  manager_id is null
  union  all
  select e.employee_id, e.first_name, e.last_name, e.hire_date, e.manager_id, oc.lvl + 1
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
) search breadth first by hire_date set hire_seq
  select * from org_chart
  order  by hire_seq;




--EXERCISE
/*
Complete the following query to return employees in depth-first order. 
You should sort employees with the same manager by first_name:
*/


select level, employee_id, first_name, last_name, hire_date, manager_id
from   employees
start  with manager_id is null
connect by prior employee_id = manager_id
order SIBLINGS by first_name;

-- DETECTING LOOPS
-- it possible to store loops in your hierarchy. usually this is a data error. 

update employees
set    manager_id = 107
where  employee_id = 100;


-- CONNECT BY
-- if you try to build a hierarchy that contains a loop, connect by throws an error

select * from employees
start with employee_id = 100
connect by prior employee_id = manager_id;

-- you can avoid this using the nocycle keyword. this spots when the query returns to the same row. 
-- the DB hides the repeated row and continues processing the tree.
select * from employees
start  with employee_id = 100
connect by nocycle prior employee_id = manager_id;

--RECURSIVE WITH

-- You control loop detection using the cycle clause of recursive with. Here you stake which columns mark a loop.
-- The DB keeps track of the values it sees in these columns. if the current row's values for these appear in one of it's ancestors.

-- cycle <columns> set <loop_column> to <loop_value> default <default_value>

WITH org_chart (
    employee_id, first_name, last_name, manager_id, department_id
) AS (
    SELECT employee_id, first_name, last_name, manager_id, department_id
    FROM EMPLOYEES
    WHERE employee_id = 100
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, e.department_id
    FROM org_chart oc
    JOIN EMPLOYEES e
    ON e.manager_id = oc.employee_id
) cycle employee_id set looped to 'Y' default 'N'
SELECT * FROM org_chart;

--unlike connect by, this includes the rows you visit twice. So the CEO, Steven king apears twice in the results
-- Using recursive with you can choose any columns in your query to mark a "loop". this allows to stop processing before you get back to the same row


with org_chart (
  employee_id, first_name, last_name, manager_id, department_id
) as (
  select employee_id, first_name, last_name, manager_id, department_id
  from   employees
  where  employee_id = 100
  union  all
  select e.employee_id, e.first_name, e.last_name, e.manager_id, e.department_id
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
) cycle department_id set looped to 'Y' default 'N'
  select * from org_chart;

-- EXERCISE
-- Complete the following query to cycle on job_id. Define a cycle column is_repeat which defaults to N. 
-- When accessing the same job_id, set it to Y

with org_chart (
  employee_id, first_name, last_name, manager_id, job_id
) as (
  select employee_id, first_name, last_name, manager_id , job_id
  from   employees
  where  employee_id = 102
  union  all
  select e.employee_id, e.first_name, e.last_name, e.manager_id, e.job_id
  from   org_chart oc
  join   employees e
  on     e.manager_id = oc.employee_id
) cycle job_id set is_repeat to 'Y' default 'N'
  select * from org_chart;





