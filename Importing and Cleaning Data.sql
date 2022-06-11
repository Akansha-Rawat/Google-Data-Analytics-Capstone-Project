
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


 SELECT * FROM Cyclistic_data


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