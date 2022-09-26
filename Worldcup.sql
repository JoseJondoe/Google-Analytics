#SQL
/*
World Cup DATA EXPLORATION 
SKILLS USED: JOINS, TEMP TABLES, WINDOWS FUNCTIONS, AGGREGATE FUNCTIONS, CREATING VIEWS
*/

------------------------------------ To view each file uploaded. There are three files (World_cup, Worldcup_players, Worldcup _matches) from Kaggle ------------------------------------

------------------------------------ First World_cup file shows the year,country where games are held at, 1st/2nd/3rd/4th positions, total goals scored in the world cup, number of qualified teams, matches played in the tournament and attendance for the world cup (Date-time is in varchar to take note) ------------------------------------


------------------------------------ Firstly to create a schema for the dataset ------------------------------------

CREATE SCHEMA worldcupseries;

SHOW VARIABLES LIKE "Local_infile";
SET GLOBAL Local_infile = 1;

USE worldcupseries;


------------------------------------ Create a first table for one of the csv files ------------------------------------

CREATE TABLE worldcupresults(
	worldcup_year INT,
    Country VARCHAR(20),
    Winner VARCHAR(20),
    Runners_Up VARCHAR(20),
    Third VARCHAR(20),
    Fourth VARCHAR(20),
    GoalsScored INT,
    QualifiedTeams INT,
    MatchesPlayed INT,
    Attendance INT
);

LOAD DATA LOCAL INFILE "C:/Users/Syed Ismail/Desktop/Web Deveploment Course/SQL/SQL Project/worldcup/world_cup_results.csv"
INTO TABLE worldcupresults
FIELDS TERMINATED BY ','
IGNORE 1 rows;


------------------------------------ To check if loaded correctly and data in the table. ------------------------------------

SELECT * FROM worldcupresults;


------------------------------------ Subsequent 2 dataset (csv files) were uploaded using the import wizard function in MYSQL workbench. ------------------------------------
 -- worldcupmatches and worldcupplayers csv.

------------------------------------ Worldcup_players file shows MatchID, Team_initials,Coach_name and Player_name ------------------------------------

SELECT 
    *
FROM
    worldcup_players
LIMIT 500000;


------------------------------------ worldcup_players table has column with spacing which may pose an issue hence to rename them by adding underscore ------------------------------------

ALTER TABLE worldcup_players
RENAME COLUMN `ï»¿RoundID` TO round_id,
RENAME COLUMN `Team Initials` TO team_initials,
RENAME COLUMN `Coach Name` TO coach_name,
RENAME COLUMN `Line-up` TO line_up,
RENAME COLUMN `Shirt Number` TO shirt_number,
RENAME COLUMN `Player Name` TO player_name;


------------------------------------ To confirm the changes made to worldcup_players ------------------------------------

SELECT 
    *
FROM
    worldcup_players
LIMIT 500000;


------------------------------------ Worldcup_matches file shows the year,datetime of the matches, stages of the game, stadium, city, Home & Away Team Name, Home & Away Team Goals, Win conditions, attendance for each match, Half-time Home and Away goals, Referee, Assistant 1 & 2, RoundID, MatchId, Home & Away team initials ------------------------------------
-- (There were error when uploading data via the table wizard and notice missing attendance in two matches, which on gooogle search showed the value)

SELECT 
    *
FROM
    worldcup_matches
LIMIT 500000;


------------------------------------ To check if there are any duplicates in players for any given match (755 rows of duplicates) ------------------------------------

SELECT 
    MatchID, Player_Name, COUNT(*) AS NumDuplicates
FROM
    worldcup_players
GROUP BY MatchID , Player_Name
HAVING NumDuplicates > 1
LIMIT 5000000;


------------------------------------ To check if there are any duplicates in matches by checking against MatchID (unique key) (16 rows of duplicates) ------------------------------------

SELECT 
    MatchID, COUNT(*) AS NumDuplicates
FROM
    worldcup_matches
GROUP BY MatchID
HAVING NumDuplicates > 1;


------------------------------------ To remove duplicates, we set up temp tables which all work will be done on. (3 temp tables to be set up for the 3 files) ------------------------------------


------------------------------------First temp table for World_cup (WC) ------------------------------------

USE worldcupseries;
CREATE TABLE temp_wc 
SELECT 
	* 
FROM
    worldcupresults;


------------------------------------ To check if all data is inputted correctly ------------------------------------

SELECT 
    *
FROM
    temp_wc;


------------------------------------ Second temp table for World_cup_players (WCP) ------------------------------------

USE worldcupseries;
CREATE TABLE temp_wcp 
SELECT 
	* 
FROM
    worldcup_players
GROUP BY MatchID , Player_Name;


------------------------------------ To check if all data is inputted correctly ------------------------------------

SELECT 
    *
FROM
    temp_wcp;


------------------------------------ To check if there are still duplicates in the temp table (0 duplicates) ------------------------------------

SELECT 
    MatchID, Player_Name, COUNT(*) AS NumDuplicates
FROM
    project.temp_wcp
GROUP BY MatchID , Player_Name
HAVING NumDuplicates > 1;


------------------------------------ Third temp table for Worldcupmatches (WCM) ------------------------------------

USE worldcupseries;
CREATE TABLE temp_wcm 
SELECT 
	* 
FROM
    worldcup_matches
GROUP BY MatchID;


------------------------------------ Temp_WC table has column with YEAR which may pose an issue hence to rename ------------------------------------

ALTER TABLE temp_wcm 
RENAME COLUMN `Year` TO wcm_year;


------------------------------------ To check if all data is inputted correctly ------------------------------------

SELECT 
    *
FROM
    temp_wcm;


------------------------------------ Notice that two countries in home_team_name and away_team_name has rn" values in their names ------------------------------------
UPDATE temp_wcm
SET    home_team_name = 
       CASE MatchID
           WHEN 119 THEN 'United Arab Emirates'
           WHEN 300186464 THEN 'Bosnia and Herzegovina'
		END
WHERE  MatchID IN (119, 300186464);

UPDATE temp_wcm
SET    away_team_name = 
       CASE MatchID
           WHEN 198 THEN 'United Arab Emirates'
           WHEN 364 THEN 'United Arab Emirates'
           WHEN 300186477 THEN 'Bosnia and Herzegovina'
           WHEN 300186511 THEN 'Bosnia and Herzegovina'
		END
WHERE  MatchID IN (198, 364,300186477,300186511);


------------------------------------ To check if data is updated ------------------------------------

SELECT 
    DISTINCT home_team_name
FROM
    temp_wcm;

SELECT 
    DISTINCT away_team_name
FROM
    temp_wcm;
    

------------------------------------ To check if there are still duplicates in the temp table (0 duplicates) ------------------------------------

SELECT 
    MatchID, COUNT(*) AS NumDuplicates
FROM
    project.temp_wcm
GROUP BY MatchID
HAVING NumDuplicates > 1;


------------------------------------ Check City name for weird symbols as noticed ------------------------------------

SELECT DISTINCT
    City
FROM
    temp_wcm;


------------------------------------ Update weird temp_wcm_city data ------------------------------------

UPDATE temp_wcm
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
			WHEN 1323 THEN 'Malmo'
			WHEN 1389 THEN 'Malmo'
			WHEN 1422 THEN 'Malmo'
			WHEN 1392 THEN 'Malmo'
       END
WHERE  MatchID IN (1386, 1423, 1385, 2181, 2066, 2065, 1995, 2182, 833, 834, 1055,1323 , 1389, 1422, 1392);


------------------------------------ Recheck City name for weird symbols (None) ------------------------------------

SELECT DISTINCT
    City
FROM
    temp_wcm;


------------------------------------ Temp_WCM table has column with spacing which may pose an issue hence to rename them by adding underscore ------------------------------------

ALTER TABLE temp_wcm 
RENAME COLUMN `Home Team Name` TO home_team_name,
RENAME COLUMN `Away Team Name` TO away_team_name,
RENAME COLUMN `Home Team Goals` TO home_team_goals,
RENAME COLUMN `Away Team Goals` TO away_team_goals,
RENAME COLUMN `Half-time Home Goals` TO Half_time_HG,
RENAME COLUMN `Half-time Away Goals` TO Half_time_AG,
RENAME COLUMN `Assistant 1` TO Assistant_1,
RENAME COLUMN `Assistant 2` TO Assistant_2,
RENAME COLUMN `Home Team Initials` TO Home_team_initials,
RENAME COLUMN `Away Team Initials` TO Away_team_initials;


------------------------------------ To check if column names has been changed correctly. (HG = Home goals, AG = Away goals) ------------------------------------

SELECT 
    *
FROM
    temp_wcm;


------------------------------------ To view number of time a country has won the world cup (Brazil with highest 5 World Cup) ------------------------------------

SELECT 
    winner, COUNT(*) AS Total_WC
FROM
    temp_wc
GROUP BY winner
ORDER BY COUNT(*) DESC;


------------------------------------ Notice that due to war, Germany had west and east during a certain period of time, hence to change Germany FR to Germany ------------------------------------

UPDATE temp_wc 
SET 
    country = 'Germany'
WHERE
    country = 'Germany FR';

UPDATE temp_wc 
SET 
    Winner = 'Germany'
WHERE
    Winner = 'Germany FR';

UPDATE temp_wc 
SET 
    Runners_up = 'Germany'
WHERE
    Runners_up = 'Germany FR';

UPDATE temp_wc 
SET 
    Third = 'Germany'
WHERE
    Third = 'Germany FR';

UPDATE temp_wc 
SET 
    Fourth = 'Germany'
WHERE
	Fourth = 'Germany FR';


------------------------------------ To confirm changes has been made to the country Germany ------------------------------------
SELECT 
    *
FROM
    temp_wc;
    

-- Average goals scored in worldcup from 1930 - 2014 (119 rounded off)

SELECT 
    ROUND(CAST(AVG(GoalsScored) AS DECIMAL)) AS Average_Goals_Scored
FROM
    temp_wc;


------------------------------------ To show which years had the min and max goals scored and the max/min goals (171 and 70 goals over 4 years, 1930/1934/1998/2014) ------------------------------------

SELECT 
    worldcup_year, GoalsScored
FROM
    temp_wc
WHERE
    GoalsScored = (SELECT 
            MAX(GoalsScored)
        FROM
            temp_wc) 
UNION ALL SELECT 
    worldcup_year, GoalsScored
FROM
    temp_wc
WHERE
    GoalsScored = (SELECT 
            MIN(GoalsScored)
        FROM
            temp_wc);


------------------------------------ To count number of time a country has won, came 2nd/3rd or 4th (Not the best solution as it is ambigous but does the job) ------------------------------------         

SELECT
  Winner, Runners_up, Third, Fourth,
  COUNT(*) OVER (PARTITION BY Winner) as Winner,
  COUNT(*) OVER (PARTITION BY Runners_up) as Runners_up,
  COUNT(*) OVER (PARTITION BY Third) as Third,
  COUNT(*) OVER (PARTITION BY Fourth) as Fourth
FROM
  temp_wc
GROUP BY
  worldcup_year;
  

------------------------------------ To count number of time a country has won, came 2nd/3rd or 4th (best solution providing accurate results) ------------------------------------

SELECT country, 
       SUM(c_result=1) AS Winner_count, 
       SUM(c_result=2) AS Runners_up_Count, 
       SUM(c_result=3) AS Third_count, 
       SUM(c_result=4) AS Fourth_Count
    FROM
(SELECT Winner AS country, 1 AS c_result FROM temp_wc UNION ALL
SELECT Runners_up, 2 FROM temp_wc UNION ALL
SELECT Third, 3 FROM temp_wc UNION ALL
SELECT Fourth, 4 FROM temp_wc) v
GROUP BY country
ORDER BY country;

------------------------------------ Creating new table to show count of winner, runner_up, third and fourth for countries participating in the World Cup ------------------------------------
USE worldcupseries;
CREATE TABLE worldcup (
    Country VARCHAR(255),
    Winner_count INT,
    Runner_up_Count INT,
    Third_count INT,
    Fourth_Count INT
);


------------------------------------ To view the new table (empty) ------------------------------------

SELECT 
    *
FROM
    worldcup;


------------------------------------ To insert the participating countries in the World Cup ------------------------------------

INSERT INTO worldcup(Country)
SELECT 
   DISTINCT `Home Team Name`
FROM 
   worldcup_matches;


------------------------------------ To update the worldcup table with info of winner,runners_up,third and fourth counts ------------------------------------

UPDATE worldcup AS wc JOIN 
(SELECT ctry, 
       SUM(c_result=1) AS Winner_count, 
       SUM(c_result=2) AS Runners_up_Count, 
       SUM(c_result=3) AS Third_count, 
       SUM(c_result=4) AS Fourth_Count
    FROM
(SELECT Winner AS ctry, 1 AS c_result FROM temp_wc UNION ALL
SELECT Runners_up, 2 FROM temp_wc UNION ALL
SELECT Third, 3 FROM temp_wc UNION ALL
SELECT Fourth, 4 FROM temp_wc) v
GROUP BY ctry) AS rs 
 ON wc.Country=rs.ctry
 SET wc.Winner_count=rs.Winner_count, 
     wc.Runner_up_Count=rs.Runners_up_Count,
     wc.Third_count=rs.Third_count,
     wc.Fourth_Count=rs.Fourth_Count;


------------------------------------ To view the updated table (a few nulls) ------------------------------------

SELECT 
    *
FROM
    worldcup;    


------------------------------------ To view the NULL value replaced with 0 without updating the table ------------------------------------

SELECT 
    Country,
    IFNULL(Winner_count, 0) AS Winner_count,
    IFNULL(Runner_up_count, 0) AS Runner_up_count,
    IFNULL(Third_count, 0) AS Third_count,
    IFNULL(Fourth_count, 0) AS Fourth_count
FROM
    worldcup;
 
 
------------------------------------ Unable to get accurate players participation as dataset includes playes as sub but did not play (Hence unusable data) ------------------------------------

SELECT 
    COUNT(*) AS Player_Appearance, Player_Name
FROM
    temp_wcp
GROUP BY Player_Name
ORDER BY Player_Appearance DESC;


------------------------------------ Calculate sum of all attendance in world cup match held from 1930 -2014 (35,985,238 total attendance) ------------------------------------

SELECT 
    SUM(temp_wc.Attendance) AS 'Total_attendance'
FROM
    temp_wc;
    

------------------------------------ Calculating % of attendance per year over total sum of attendance for 1930 - 2014 rounded up to 2 decimal place using subquery at Select statement ------------------------------------

SELECT
	worldcup_year, Round((temp_wc.Attendance/ (SELECT
		SUM(temp_wc.Attendance)
	FROM
		temp_wc)*100),2) AS 'Percentage_peryear_total'
From
	temp_wc
GROUP BY worldcup_year
ORDER BY Percentage_peryear_total DESC;


------------------------------------ Using CTE to left Join for two tables.------------------------------------

WITH temp_CTE AS
(SELECT 
    temp_wcm.wcm_year AS 'worldcup_year',
    City AS 'worldcup_match_city',
    Datetime AS 'date_time',
    Stadium AS 'match_stadium',
    temp_wcm.Attendance AS 'match_attendance',
    Country AS 'worldcup_country',
    Winner AS 'worldcup_winner',
    GoalsScored AS 'total-goals-scored',
    temp_wc.Attendance AS 'worldcup_attendance',
    MatchID AS 'match_id'
FROM
    temp_wcm
        LEFT JOIN
    temp_wc ON temp_wc.worldcup_year = temp_wcm.wcm_year)
    SELECT *
    FROM temp_CTE;


------------------------------------ Create view for dashboard ------------------------------------

DROP VIEW IF EXISTS dashboard;
CREATE VIEW dashboard AS
    SELECT 
        temp_wcm.wcm_year AS 'worldcup_year',
        City AS 'worldcup_match_city',
        Datetime AS 'date_time',
        Stadium AS 'match_stadium',
        temp_wcm.Attendance AS 'match_attendance',
        Country AS 'worldcup_country',
        Winner AS 'worldcup_winner',
        GoalsScored AS 'total-goals-scored',
        temp_wc.Attendance AS 'worldcup_attendance'
    FROM
        temp_wcm
            LEFT JOIN
        temp_wc ON temp_wcm.wcm_year = temp_wc.worldcup_year;


------------------------------------ View dashboard data ------------------------------------

SELECT 
    *
FROM
    dashboard;


------------------------------------ To see if view dashboard works ------------------------------------

SELECT DISTINCT
    (worldcup_match_city)
FROM
    dashboard;


------------------------------------ Count of distinct city world cup matches played at (151 cities) ------------------------------------

SELECT 
    COUNT(DISTINCT worldcup_match_city)
FROM
    dashboard;
    

------------------------------------ Max attendance in a match to see only one row using subquery at Where statement (1950 in Rio, 1,045,246 attendance) ------------------------------------

SELECT 
    *
FROM
    dashboard
WHERE
    match_attendance IN (SELECT 
            MAX(match_attendance)
        FROM
            dashboard);


------------------------------------ Checking if Worldcup attendance tally with sum of all match attendance ------------------------------------

SELECT 
    *, SUM(match_attendance) AS total_match_attendance
FROM
    dashboard
GROUP BY worldcup_year;


------------------------------------ To confirm if 2014 had difference of sum match attendance in the year against calculated world cup attendance of the year (There is a discrepancy) ------------------------------------

SELECT 
    SUM(match_attendance) AS total_match_attendance,
    Worldcup_year,
    worldcup_attendance
FROM
    dashboard
WHERE
    worldcup_year = '2014';


------------------------------------ values for Worldcup_results for row 2, 3 and 6 missing zeros ------------------------------------
    
UPDATE temp_wc
SET    Attendance = 
       CASE worldcup_year
           WHEN 1934 THEN '363000'
           WHEN 1938 THEN '375700'
           WHEN 1958 THEN '819810'
       END
WHERE  temp_wc.worldcup_year IN (1934, 1938, 1958);


------------------------------------ Checking the update has been successful ------------------------------------

SELECT 
    *
FROM
    temp_wc;


------------------------------------ Drop view to create new view ------------------------------------

DROP VIEW dashboard;


------------------------------------ To check if dashboard view has been dropped ------------------------------------

SELECT 
    *
FROM
    dashboard;


------------------------------------ Create new view with all three tables combine ------------------------------------

CREATE VIEW dashboard AS
    SELECT 
        wcp.round_id,
        wcp.MatchID,
        wcp.team_initials,
        wcp.coach_name, 
        wcp.line_up, 
        wcp.shirt_number, 
        wcp.player_name, 
        wcm.wcm_year, 
        wcm.Datetime, 
        wcm.Stage, 
        wcm.Stadium, 
        wcm.City, 
        wcm.home_team_name, 
        wcm.home_team_goals, 
        wcm.away_team_goals, 
        wcm.away_team_name, 
        wcm.Attendance, 
        wcm.Half_time_HG, 
        wcm.Half_time_AG, 
        wcm.Referee, 
        wcm.Assistant_1, 
        wcm.Assistant_2, 
        wcm.Home_team_initials, 
        wcm.Away_team_initials
    FROM
        temp_wcp AS wcp
            INNER JOIN
        temp_wcm AS wcm ON wcp.MatchId = wcm.MatchId;
 
 
------------------------------------ To check final dashboard view (Used for PowerBI visualization) ------------------------------------

SELECT 
    *
FROM
    dashboard;
