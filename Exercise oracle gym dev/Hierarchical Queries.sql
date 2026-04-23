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







