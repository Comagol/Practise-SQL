drop table match_results cascade constraints;
create table match_results (
  match_date       date,
  location         varchar2(20),
  home_team_name   varchar2(20),
  away_team_name   varchar2(20),
  home_team_points integer,
  away_team_points integer
);

insert into match_results values ( date'2018-01-01', 'Snowley', 'Underrated United', 'Terrible Town', 2, 0 );
insert into match_results values ( date'2018-01-01', 'Coldgate', 'Average Athletic', 'Champions City', 1, 4 );
insert into match_results values ( date'2018-02-01', 'Dorwall', 'Terrible Town', 'Average Athletic', 0, 1 );
insert into match_results values ( date'2018-03-01', 'Coldgate', 'Average Athletic', 'Underrated United', 3, 3 );
insert into match_results values ( date'2018-03-02', 'Newdell', 'Champions City', 'Terrible Town', 8, 0 );

commit;

SELECT * FROM match_results;

--how many matchs where played in each location
SELECT location, COUNT(*)
FROM MATCH_RESULTS
GROUP BY location;

--now lets change the rows to columns
--manual pivot
select count ( case when location = 'Snowley' then 1 end ) snowley,
       count ( case when location = 'Coldgate' then 1 end ) coldgate,
       count ( case when location = 'Dorwall' then 1 end ) dorwall,
       count ( case when location = 'Newdell' then 1 end ) newdell
from   match_results;

--here is when the pivot clause comes usefull
--To use it, specify three things:

--The values to go in the location columns. You want a count, so this is count(*)
--The column containing values you want to become new columns. Here that's location
--The list of values to become columns. This is the names of the locations.

WITH RWS AS (
    SELECT LOCATION FROM MATCH_RESULTS
)
SELECT * FROM RWS
PIVOT (
    COUNT (*) FOR LOCATION IN (
        'Snowley', 'Coldgate', 'Dorwall', 'Newdell'
    )
);

--FIRST EXERCISE
--Complete this query to show the locations as columns, with date of the last match played in each:

--Hint: to find the last date in a set, use max
with rws as (
  select location, match_date from match_results
)
select * from rws
pivot (
  MAX(MATCH_DATE) for location in (
    'Snowley', 'Coldgate', 'Dorwall', 'Newdell' 
  )
);

--Complete this query to show the team names as columns, with the number of home games each has played:
with rws as (
  select home_team_name from match_results
)
select * from rws
pivot (
  count (*) for HOME_TEAM_NAME 
  in (
    'Underrated United', 'Average Athletic', 'Terrible Town', 'Champions City'
  )
);

--Implicit Group BY

select * 
from MATCH_RESULTS
pivot (
  count(*) for location in (
    'Snowley', 'Coldgate', 'Dorwall', 'Newdell'
  )
);

--EXPRESIONS
WITH RWS AS (
    SELECT match_date from match_results
)
SELECT * FROM RWS
PIVOT (
    COUNT (*) FOR TO_CHAR (match_date, 'MON') IN (
     'JAN', 'FEB', 'MAR'    
    )
);

with rws as (
  select to_char ( match_date, 'MON' ) match_month
  from   match_results
)
select * from rws
pivot (
  count (*) for match_month in (
   'JAN', 'FEB', 'MAR'
  )
);

--FILTERING PIVOTED ROWS
WITH rws AS (
    SELECT location, TO_CHAR ( match_date,  'MON' ) match_month
    FROM match_results
)
SELECT * FROM RWS
PIVOT ( 
    COUNT (*) FOR match_month IN (
        'JAN', 'FEB', 'MAR'
    )    
);


--adding a where clause
WITH rws AS (
    SELECT location, TO_CHAR ( match_date,  'MON' ) match_month
    FROM match_results
)
SELECT * FROM RWS
PIVOT ( 
    COUNT (*) FOR match_month IN (
        'JAN', 'FEB', 'MAR'
    )    
)
WHERE "'JAN'" > 0

--NEW COLUMN NAMES
-- BY DEFAULT THE NAMES OF THE COLUMNS ARE TE VALUES DRON THE UN LIST, WRAPPED IN QUOTES
--THE NEW NAME GOES AFTER THE 'JUN' JUN_NEW_NAME

WITH rws AS (
    SELECT location, TO_CHAR ( match_date,  'MON' ) match_month
    FROM match_results
)
SELECT * FROM RWS
PIVOT ( 
    COUNT (*) FOR match_month IN (
        'JAN' JAN, 'FEB' FEBE, 'MAR' MARCH
    )    
);


--adding a where clause
WITH rws AS (
    SELECT location, TO_CHAR ( match_date,  'MON' ) match_month
    FROM match_results
)
SELECT * FROM RWS
PIVOT ( 
    COUNT (*) FOR match_month IN (
        'JAN' JAN, 'FEB' FEB, 'MAR' MAR
    )    
)
WHERE JAN > 0

--EXERCISE
--Complete the following query to show:

--For each location, the number of games played on each day of the week
--The three letter abbreviation of each day as columns
--The column headings without quotes
--Those locations that had one or more games played on Monday

with rws as ( 
  select location,
        to_char ( match_date, 'DY' ) match_day
  from match_results
)
select * from rws
pivot (
  count (*) for match_day in (
    'MON' MON, 'TUE' TUE, 'WED' WED, 'THU' THU,
    'FRI' FRI, 'SAT' SAT, 'SUN' SUN
      )
)
where mon >0
order by location

--PIVOTING MANY VALUES

WITH rws AS (
    SELECT location, TO_CHAR ( match_date, 'MON' ) match_month ,
    home_team_points, away_team_points
    FROM match_results
)
SELECT * FROM RWS 
PIVOT (
    COUNT (*) matches,
    sum ( home_team_points) home_points,
    sum ( away_team_points ) away_points 
    FOR match_month in (
        'JAN' JAN, 'FEB' FEB, 'MAR' MAR
    )
);

--EXERCISE
--Complete the following query to show for each location:

--A column counting the number of games played
--The total number of points scored at each location ( home_team_points + away_team_points )
--The count columns should have the matches suffix. The total points scored the suffix points

with rws as (
  select location, home_team_points, away_team_points
  from   match_results
)
select * from rws
pivot (
  COUNT(*) matches,
  sum(home_team_points + away_team_points)
   for location in (
    'Snowley' snowley, 'Coldgate' coldgate, 
    'Dorwall' dorwall, 'Newdell' newdell
  )
)

--dynamic pivoting
with rws as (
  select location
  from   match_results
)
select xmlserialize ( -- formats an XML document
         document location_xml as clob indent size=2
       ) location_xml
from   rws
pivot xml (
  count (*) matches for location in ( any )
);

--unpivoting
select match_date, location, 'HOME' home_or_away, home_team_name team
from   match_results
union  all
select match_date, location, 'AWAY' home_or_away, away_team_name team
from   match_results
order  by match_date, location, home_or_away;


--unpivoting clause
select match_date, location, home_or_away, team 
from   match_results
unpivot (
  team for home_or_away in ( 
    home_team_name as 'HOME', away_team_name as 'AWAY'
  )
)
order  by match_date, location, home_or_away;

--exercise
--Complete the following query to unpivot the home and away points for each match:

select match_date, location, home_or_away, points
from   match_results
unpivot (
  points for 
  home_or_away in (
    home_team_points as 'HOME', away_team_points as 'AWAY'
  )
)
order  by match_date, location, home_or_away;





