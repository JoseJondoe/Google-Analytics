# Google-Analytics
Capstone project for Google Analytics

/*
World Cup DATA EXPLORATION 
SKILLS USED: JOINS, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS
*/

-- To view the table of world_cup_matches
SELECT 
    *
FROM
    project.worldcupmatches;

-- To view the table of world_cup_matches
SELECT 
    *
FROM
    project.world_cup;
    
-- Alter Year column name for table world_cup
ALTER TABLE world_cup
CHANGE COLUMN Year worldcup_year INT;

-- Alter Year column name for table worldcupmatches
ALTER TABLE worldcupmatches
CHANGE COLUMN Year worldcupmatches_year INT;

-- Calculate sum of all attendance in world cup match held from 1930 -2014
SELECT 
    SUM(world_cup.Attendance) AS 'Total_attendance'
FROM
    project.world_cup;

-- Calculating % of attendance per year over total sum of attendance for 1930 - 2014 rounded up to 2 decimal place using subquery at Select statement
SELECT
	worldcup_year, Round((world_cup.attendance/ (SELECT
		SUM(world_cup.Attendance)
	FROM
		project.world_cup)*100),2) AS 'Percentage_peryear_total'
From
	project.world_cup
GROUP BY worldcup_year;

-- Join two tables to get desired outcome
SELECT 
    worldcupmatches.worldcupmatches_year AS 'worldcup_year',
    City AS 'worldcup_match_city',
    Datetime AS 'date_time',
    Stadium AS 'match_stadium',
    worldcupmatches.Attendance AS 'match_attendance',
    Country AS 'worldcup_country',
    Winner AS 'worldcup_winner',
    GoalsScored AS 'total-goals-scored',
    world_cup.Attendance AS 'worldcup_attendance',
    MatchID AS 'match_id'
FROM
    project.worldcupmatches
        LEFT JOIN
    project.world_cup ON world_cup.worldcup_year = worldcupmatches.worldcupmatches_year;

-- Update weird worldcup_match_city data
UPDATE project.worldcupmatches
SET    City = 
       CASE MatchID
            WHEN 1386 THEN 'Norrkopings'
            WHEN 1423 THEN 'Norrkopings'
            WHEN 1385 THEN 'Norrkopings'
            WHEN 2181 THEN 'Dusseldorf'
            WHEN 2066 THEN 'Dusseldorf'
            WHEN  2065 THEN 'Dusseldorf'
            WHEN  1995 THEN 'Dusseldorf'
            WHEN  2182 THEN 'Dusseldorf'
            WHEN  833 THEN 'A Coruna'
            WHEN  834 THEN 'A Coruna'
            WHEN  1055 THEN 'A Coruna'
       END
WHERE  MatchID IN (1386, 1423, 1385, 2181, 2066, 2065, 1995, 2182, 833, 834, 1055);

-- View distinct city if updated correctly
SELECT DISTINCT
    (City)
FROM
    project.worldcupmatches;

-- Malmo not update, so reupdate worldcupmatches table
UPDATE project.worldcupmatches 
SET 
    City = CASE MatchID
        WHEN 1323 THEN 'Malmo'
        WHEN 1389 THEN 'Malmo'
        WHEN 1422 THEN 'Malmo'
        WHEN 1392 THEN 'Malmo'
    END
WHERE
    MatchID IN (1323 , 1389, 1422, 1392);

-- View distinct city if updated correctly once again
SELECT DISTINCT
    (City)
FROM
    project.worldcupmatches;

-- To indicate which database to use for view
USE project;

-- Create view for dashboard
CREATE VIEW dashboard AS
    SELECT 
        worldcupmatches.worldcupmatches_year AS 'worldcup_year',
        City AS 'worldcup_match_city',
        Datetime AS 'date_time',
        Stadium AS 'match_stadium',
        worldcupmatches.Attendance AS 'match_attendance',
        Country AS 'worldcup_country',
        Winner AS 'worldcup_winner',
        GoalsScored AS 'total-goals-scored',
        world_cup.Attendance AS 'worldcup_attendance'
    FROM
        project.worldcupmatches
            LEFT JOIN
        project.world_cup ON worldcupmatches.worldcupmatches_year = world_cup.worldcup_year;

-- View dashboard data
SELECT 
    *
FROM
    dashboard;

-- To see if view dashboard works
SELECT DISTINCT
    (worldcup_match_city)
FROM
    dashboard;

-- Count of distinct city world cup matches played at
SELECT 
    COUNT(DISTINCT worldcup_match_city)
FROM
    dashboard;

-- View column changes on both table
SELECT 
    *
FROM
    project.worldcupmatches;
SELECT 
    *
FROM
    project.world_cup;

-- Drop view to create new view
DROP VIEW dashboard;

-- To check if dahsbord view has been dropped
SELECT 
    *
FROM
    dashboard;

-- Create new dashboard view with column name change on both tables
CREATE VIEW new_dashboard AS
    SELECT 
        worldcupmatches.worldcupmatches_year AS 'worldcup_year',
        City AS 'worldcup_match_city',
        Datetime AS 'date_time',
        Stadium AS 'match_stadium',
        worldcupmatches.Attendance AS 'match_attendance',
        Country AS 'worldcup_country',
        Winner AS 'worldcup_winner',
        GoalsScored AS 'total-goals-scored',
        world_cup.Attendance AS 'worldcup_attendance'
    FROM
        project.worldcupmatches
            LEFT JOIN
        project.world_cup ON worldcupmatches.worldcupmatches_year = world_cup.worldcup_year;

-- View new dashboard
SELECT 
    *
FROM
    new_dashboard;

-- Max attendance in a match
SELECT 
    *
FROM
    new_dashboard
ORDER BY match_attendance DESC;

-- Max attendance in a match to see only one row using subquery at Where statement
SELECT 
    *
FROM
    new_dashboard
WHERE
    match_attendance IN (SELECT 
            MAX(match_attendance)
        FROM
            new_dashboard);

-- Checking if Worldcup attendance tally with sum of all match attendance
SELECT 
    *, SUM(match_attendance) AS total_match_attendance
FROM
    new_dashboard
GROUP BY worldcup_year;

-- To confirm if 2014 had difference of sum match attendance in the year against calculated world cup attendance of the year
SELECT 
    SUM(match_attendance) AS total_match_attendance,
    Worldcup_year,
    worldcup_attendance
FROM
    new_dashboard
WHERE
    worldcup_year = '2014';

-- Create Temp Table
CREATE TEMPORARY TABLE Temp_worldcup
SELECT 
		world_cup.worldcup_year AS 'worldcup_year', Country, world_cup.attendance AS 'Attendance_year',
		worldcupmatches.attendance AS 'match_attendance'
FROM 
		project.world_cup
Left Join
		project.worldcupmatches
	ON	worldcupmatches.worldcupmatches_year = world_cup.worldcup_year;

-- Check temp table    
SELECT 
    *
FROM
    temp_worldcup;

-- Drop temp table
Drop TEMPORARY TABLE Temp_worldcup;

-- Check temp table if still exist   
SELECT 
    *
FROM
    temp_worldcup;
