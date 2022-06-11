
 CREATE TABLE Cyclistic_data
   (  ride_id varchar(250) NULL,
	  rideable_type varchar(250) NULL,
	  started_at datetime NULL,
	  ended_at datetime NULL,
	  start_station_name varchar(250) NULL,
	  start_station_id varchar(250) NULL,
	  end_station_name varchar(250) NULL,
	  end_station_id varchar(250) NULL,
	  start_lat decimal(4,2) NULL,
	  start_lng decimal(4,2) NULL,
	  end_lat decimal(4,2) NULL,
	  end_lng decimal(4,2) NULL,
	  member_casual char
	)

 SELECT * FROM Cyclistic_data
 SELECT * FROM FilePath


------------------------------------------------------------------------------------------
----------------------------IMPORTING 12 CSV FILES----------------------------------------
------------------------(using bulk insert and cursor)------------------------------------

 DECLARE @mysqltext nvarchar(250)
 DECLARE @mypath nvarchar(250)
 DECLARE mycursor cursor forward_only
        for SELECT File_path FROM FilePath

   OPEN mycursor

      FETCH NEXT FROM mycursor INTO @mypath
   WHILE @@FETCH_STATUS = 0
      BEGIN

	     SET @mysqltext =
		 'BULK INSERT Cyclistic_data
		      FROM '''+ @mypath +
			  ''' WITH
			  (
			     FIRSTROW = 2,
				 FIELDTERMINATOR = '','',
				 ROWTERMINATOR = ''\n''
			  )'
	  --PRINT @mysqltext

	  EXECUTE sp_executesql @mysqltext

	  --PRINT @mypath
	  FETCH NEXT FROM mycursor INTO @mypath
	  END

   CLOSE mycursor
   DEALLOCATE mycursor



--------------------------------------------------------------------------------------------------
----------------------------ANALYSING THE DATA FOR CLEANING---------------------------------------
--------------------------------------------------------------------------------------------------

--                                         ride_id
/*
  Check whether the length of ride_id is same for all rows 
  AND check all the values are unique from each other as ride_id will be our primary key.
*/

 SELECT LEN(ride_id) AS id_length, count(*) AS CountRow
 FROM Cyclistic_data
 GROUP BY LEN(ride_id)

 SELECT COUNT(DISTINCT ride_id) AS CountRows
 FROM Cyclistic_data

/* NOTES:
All ride_id strings are 16 characters long and they are all distinct. 
No cleaning neccesary on this column.
*/



--                                      rideable_type 
/* Check the types of bikes customers are using for thei ride */

 SELECT DISTINCT rideable_type
 FROM Cyclistic_data



--                                 started_at and ended_at columns
/* 
Check started_at and ended_at columns.
We only want the rows where the time length of the ride longer than 1 minute,
but shorter than one day(1440 minutes).
*/

 SELECT *
 FROM Cyclistic_data
 WHERE DATEDIFF(MINUTE, ended_at, started_at) <= 1 OR
       DATEDIFF(MINUTE, ended_at, started_at) >= 1440



--                          start/end station name and start/end station id
/*
  A look on the start/end station name/id columns 
*/

 SELECT start_station_name, COUNT(*) AS CountRow
 FROM Cyclistic_data
 GROUP BY start_station_name
 ORDER BY 1

 SELECT end_station_name, COUNT(*) AS CountRow
 FROM Cyclistic_data
 GROUP BY end_station_name
 ORDER BY 1

 SELECT COUNT(DISTINCT(start_station_name)) AS unq_startname,
        COUNT(DISTINCT(end_station_name)) AS unq_endname,
        COUNT(DISTINCT(start_station_id)) AS unq_startid,
        COUNT(DISTINCT(end_station_id)) AS unq_endid
 FROM Cyclistic_data


/* Check NULLS in start and end station name columns */

 SELECT rideable_type, COUNT(*) AS num_of_rides
 FROM Cyclistic_data
 WHERE start_station_name IS NULL AND start_station_id IS NULL OR
       end_station_name IS NULL AND end_station_id IS NULL 
 GROUP BY rideable_type

 -- NOTE: We will be deleting NULL value rows of Start and End staion names and ids 



--                                    start/end latitude and longitude
/* Check rows were latitude and longitude are null */

 SELECT *
 FROM Cyclistic_data
 WHERE start_lat IS NULL OR
       start_lng IS NULL OR
       end_lat IS NULL OR
       end_lng IS NULL

-- NOTE: we will remove these rows as all rows should have location points



--                                member_casual column
/* Confirm that there are only 2 member types in the member_casual column */

 SELECT DISTINCT member_casual
 FROM Cyclistic_data

/*
  NOTE: Yes the only values in this field are 'member' or 'casual'
*/



--------------------------------CLEANING THE DATA-------------------------------------------------
--------------------------------DELETING SOME DATA------------------------------------------------
----------------------(Data that might bias the end result)---------------------------------------

-- Start/End station names AND Start/End station ids having NULL values all together
 SELECT * FROM Cyclistic_data
 WHERE start_station_name IS NULL AND start_station_id IS NULL 
      AND end_station_name IS NULL AND end_station_id IS NULL

 DELETE FROM Cyclistic_data
 WHERE start_station_name IS NULL AND start_station_id IS NULL 
      AND end_station_name IS NULL AND end_station_id IS NULL
 /*
   These rows having NULL values all together are of no use to us, also may lead to biased results.
 */


-- Start/End latitude and longitude rows being NULL. Location should be mention if a ride is taken
 SELECT *
 FROM Cyclistic_data
 WHERE start_lat IS NULL OR start_lng IS NULL OR
       end_lat IS NULL OR end_lng IS NULL

 DELETE FROM Cyclistic_data
 WHERE start_lat IS NULL OR start_lng IS NULL OR
       end_lat IS NULL OR end_lng IS NULL


--------------------------------------------------------------------------------------------------
-----------------------------ALTERING AND UPDATING SOME COLUMNS-----------------------------------
--------------------------------------------------------------------------------------------------

 ALTER TABLE Cyclistic_data
 ADD ride_length time

 UPDATE Cyclistic_data
 SET ride_length =  ended_at - started_at

 ALTER TABLE Cyclistic_data
 ADD day_of_week1 tinyint

 UPDATE Cyclistic_data
 SET day_of_week = DATEPART(weekday, started_at)



--------------------------------------------------------------------------------------------------
------------------------ANALYSING THE DATA FOR VIZUALIZATION--------------------------------------
--------------------------------------------------------------------------------------------------

--Number of rides by each type(classic,docked,electric) of bike 
 SELECT rideable_type, COUNT(rideable_type) AS num_of_rides, member_casual
 FROM Cyclistic_data
 GROUP BY rideable_type, member_casual
 ORDER BY 2 DESC

--Number of Rides by customer type(member, casual)
 SELECT member_casual, COUNT(member_casual) AS num_of_rides
 FROM Cyclistic_data
 GROUP BY member_casual

--Avg ride_length by customer type(member, casual)
 SELECT member_casual, CAST(DATEADD( ms,AVG(CAST(DATEDIFF( ms, '00:00:00', ISNULL(ride_length, '00:00:00')) AS bigint)), '00:00:00' )  AS TIME(0)) AS 'Avg_duration_of_ride'
 FROM Cyclistic_data
 GROUP BY member_casual

--Average ride_length for users by day_of_week
 SELECT DATENAME(dw,day_of_week) AS Day, CAST(DATEADD( ms,AVG(CAST(DATEDIFF( ms, '00:00:00', ISNULL(ride_length, '00:00:00')) AS bigint)), '00:00:00' )  AS TIME(0)) AS 'Avg_duration_of_ride'
 FROM Cyclistic_data
 GROUP BY day_of_week
 ORDER BY Avg_duration_of_ride DESC

--Mean of ride_length
 SELECT Cast(CAST(DATEADD( ms,AVG(CAST(DATEDIFF( ms, '00:00:00', ISNULL(ride_length, '00:00:00')) AS bigint)), '00:00:00' )  AS TIME(0)) AS nvarchar(50)) AS 'Avg_duration_of_ride'
 FROM Cyclistic_data

--Mode of count of ride by day_of_week
 SELECT Datename(dw,day_of_week) AS Day_of_week, COUNT(*) AS Mode_of_rides
 FROM  Cyclistic_data
 GROUP  BY day_of_week 
 ORDER  BY 2 DESC

--Number of rides of MEMBERS(customer type) by Month
 SELECT DISTINCT DATENAME(mm,started_at) AS Month, COUNT(started_at) AS num_of_rides_members
 FROM Cyclistic_data
 WHERE member_casual = 'member'
 GROUP BY DATENAME(mm,started_at)
 ORDER BY 2 DESC

--Number of rides of Casuals(customer type) by Month
 SELECT DISTINCT DATENAME(mm,started_at) AS Month, COUNT(started_at) As num_of_rides_casuals
 FROM Cyclistic_data
 WHERE member_casual = 'casual'
 GROUP BY DATENAME(mm,started_at)
 ORDER BY 2 DESC

--Total number of rides by month
 SELECT DISTINCT DATENAME(mm,started_at) AS Month, COUNT(started_at) AS num_of_rides, member_casual
 FROM Cyclistic_data
 GROUP BY DATENAME(mm,started_at), member_casual
 ORDER BY 2 DESC


-- Number pf rides by months and seasons
 SELECT DISTINCT DATENAME(mm,started_at) AS Month, COUNT(started_at) AS num_of_rides, member_casual,
  (
   CASE
 	   WHEN DATENAME(mm,started_at) LIKE 'January' OR
 	   DATENAME(mm,started_at) LIKE 'February' OR 
	   DATENAME(mm,started_at) LIKE 'December' THEN 'Winter'
	   WHEN DATENAME(mm,started_at) LIKE 'March' OR
	   DATENAME(mm,started_at) LIKE 'April' OR
	   DATENAME(mm,started_at) LIKE 'May' THEN 'Spring'
	   WHEN DATENAME(mm,started_at) LIKE 'June'OR
	   DATENAME(mm,started_at) LIKE 'July' OR 
	   DATENAME(mm,started_at) LIKE 'August' THEN 'Summer'
	   WHEN DATENAME(mm,started_at) LIKE 'September' OR
	   DATENAME(mm,started_at) LIKE 'October' OR 
	   DATENAME(mm,started_at) LIKE 'November' THEN 'Autumn'
    END) AS Season
 FROM Cyclistic_data
 GROUP BY DATENAME(mm,started_at), member_casual,
   (
    CASE
	   WHEN DATENAME(mm,started_at) LIKE 'January' OR
	   DATENAME(mm,started_at) LIKE 'February' OR 
   	   DATENAME(mm,started_at) LIKE 'December' THEN 'Winter'
	   WHEN DATENAME(mm,started_at) LIKE 'March' OR
	   DATENAME(mm,started_at) LIKE 'April' OR 
	   DATENAME(mm,started_at) LIKE 'May' THEN 'Spring'
	   WHEN DATENAME(mm,started_at) LIKE 'June' OR
	   DATENAME(mm,started_at) LIKE 'July' OR 
	   DATENAME(mm,started_at) LIKE 'August' THEN 'Summer'
	   WHEN DATENAME(mm,started_at) LIKE 'September' OR
	   DATENAME(mm,started_at) LIKE 'October' OR 
	   DATENAME(mm,started_at) LIKE 'November' THEN 'Autumn'
    END )
 ORDER BY num_of_rides DESC


--Number of rides of members(customer type) by Weekday
 SELECT DISTINCT DATENAME(dw,day_of_week) AS Weekday, COUNT(day_of_week) AS num_of_rides_members
 FROM Cyclistic_data
 WHERE member_casual = 'member'
 GROUP BY day_of_week
 ORDER BY 2 DESC


--Number of rides of casuals(customer type) by Weekday
 SELECT DISTINCT DATENAME(dw,day_of_week) AS Weekday, COUNT(day_of_week) AS num_of_rides_casuals
 FROM Cyclistic_data
 WHERE member_casual = 'casual'
 GROUP BY day_of_week
 ORDER BY 2 DESC


--Total number of rides by day of week
 SELECT DISTINCT DATENAME(dw,day_of_week) AS day_of_week, COUNT(day_of_week) AS num_of_rides, member_casual,
    (
	  CASE
	      WHEN CAST(started_at AS time(0)) >= '06:00:00' AND CAST(started_at AS time(0)) < '12:00:00' THEN 'Morning'
	      WHEN CAST(started_at AS time(0)) >= '12:00:00' AND Cast(started_at AS time(0)) < '17:00:00' THEN 'Afternoon'
	      WHEN CAST(started_at AS time(0)) >= '17:00:00' AND CAST(started_at AS time(0)) < '20:00:00' THEN 'Evening'
	      ELSE 'Night'
      END ) AS time_of_day
 FROM Cyclistic_data
 GROUP BY day_of_week, member_casual,
    ( 
	  CASE
	      WHEN CAST(started_at AS time(0)) >= '06:00:00' AND CAST(started_at AS time(0)) < '12:00:00' THEN 'Morning'
	      WHEN CAST(started_at AS time(0)) >= '12:00:00' AND CAST(started_at AS time(0)) < '17:00:00' THEN 'Afternoon'
	      WHEN CAST(started_at AS time(0)) >= '17:00:00' AND CAST(started_at AS time(0)) < '20:00:00' THEN 'Evening'
	      ELSE 'Night'
       END )
 ORDER BY day_of_week, 2 DESC


--Number of rides by Weekday/ Weekend
 SELECT DISTINCT DATENAME(dw,day_of_week) AS day_of_week, COUNT(day_of_week) AS num_of_rides,
    (
	  CASE
	      WHEN DATENAME(dw,day_of_week) = 'Saturday' OR  DATENAME(dw,day_of_week) = 'Sunday' THEN 'Weekend'
	      ELSE 'Weekday'
	  END ) AS Weekday_Weekend
 FROM Cyclistic_data
 GROUP BY day_of_week, member_casual,
    (
	  CASE
	      WHEN DATENAME(dw,day_of_week) = 'Saturday' OR  Datename(dw,day_of_week) = 'Sunday' THEN 'Weekend'
	      ELSE 'Weekday'
	  END )
 ORDER BY day_of_week, 2 DESC


--Number of rides by casual riders by day of the week
 SELECT DISTINCT DATENAME(dw,day_of_week) AS Weekday, COUNT(day_of_week) AS num_of_rides
 FROM Cyclistic_data
 WHERE member_casual = 'casual'
 GROUP BY day_of_week
 ORDER BY 2 DESC


--Number of rides by month and time of the day(Morning, Afternoon, Evening, Night) and avg time
 SELECT DISTINCT DATENAME(mm,started_at) AS Month,
    (
	  CASE
	      WHEN CAST(started_at AS time(0)) >= '06:00:00' AND CAST(started_at AS time(0)) < '12:00:00' THEN 'Morning'
	      WHEN CAST(started_at AS time(0)) >= '12:00:00' AND CAST(started_at AS time(0)) < '17:00:00' THEN 'Afternoon'
	      WHEN CAST(started_at AS time(0)) >= '17:00:00' AND CAST(started_at AS time(0)) < '20:00:00' THEN 'Evening'
	      ELSE 'Night'
       END) AS time_of_day, COUNT(started_at) AS num_of_rides, CAST(CAST(DATEADD( ms,AVG(CAST(DATEDIFF( ms, '00:00:00', ISNULL(ride_length, '00:00:00')) AS bigint)), '00:00:00' )  AS TIME(0)) AS varchar(50)) AS 'Avg_time', member_casual

 FROM Cyclistic_data
 GROUP BY 
    (
	  CASE
	      WHEN CAST(started_at AS time(0)) >= '06:00:00' AND CAST(started_at AS time(0)) < '12:00:00' THEN 'Morning'
	      WHEN CAST(started_at AS time(0)) >= '12:00:00' AND CAST(started_at AS time(0)) < '17:00:00' THEN 'Afternoon'
	      WHEN CAST(started_at AS time(0)) >= '17:00:00' AND CAST(started_at AS time(0)) < '20:00:00' THEN 'Evening'
	      ELSE 'Night'
      END ), DATENAME(mm,started_at), member_casual
 ORDER BY month, num_of_rides DESC


--Number of rides of casual riders by station name
 SELECT DISTINCT start_station_name AS station_name, COUNT(start_station_name) AS num_of_rides_started, COUNT(end_station_name) AS num_of_rides_ended, member_casual
 FROM Cyclistic_data
 GROUP BY start_station_name, member_casual
 ORDER BY num_of_rides_started DESC, num_of_rides_ended DESC


-- Number of rides by time of the day
 SELECT DATEPART(HOUR, started_at) AS Hour, COUNT(started_at) AS num_of_rides, member_casual
 FROM Cyclistic_data
 GROUP BY DATEPART(HOUR, started_at), member_casual
 ORDER BY Hour
