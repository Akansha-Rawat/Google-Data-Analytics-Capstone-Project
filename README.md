# Google-Data-Analytics-Capstone-Project

## INTRODUCTION 
For the capstone project, I have selected the Cyclistic bike share analysis case study to work on. For the case study, I will perform the real-world tasks of a junior data analyst for marketing team at Cyclistic, a fictional bike share company in Chicago.
To answer the key business questions, I followed the six steps of the data analysis process taught in the course which are : **Ask, Prepare, Process, Analyse, Share and Act**.
-	Detailed documentation of code is available here (Github link).
-	Data cleaning, validation, and exploration using MS SQL.
-	Data visualization using Tableau Public. 

## BACKGROUND 
**Cyclistic:** A bike-share program that features more than 5,800 bicycles and 600 docking stations. Cyclistic sets itself apart by also offering reclining bikes, hand tricycles, and cargo bikes, making bike-share more inclusive to people with disabilities and riders who can’t use a standard two-wheeled bike. The majority of riders opt for traditional bikes; about 8% of riders use the assistive options. Cyclistic users are more likely to ride for leisure, but about 30% use them to commute to work each day. 

**Lily Moreno:** The director of marketing and your manager. Moreno is responsible for the development of campaigns and initiatives to promote the bike-share program. These may include email, social media, and other channels. 

**Cyclistic marketing analytics team:** A team of data analysts who are responsible for collecting, analyzing, and reporting data that helps guide Cyclistic marketing strategy. You joined this team six months ago and have been busy learning about Cyclistic’s mission and business goals — as well as how you, as a junior data analyst, can help Cyclistic achieve them. 

**Cyclistic executive team:** The notoriously detail-oriented executive team will decide whether to approve the recommended marketing program.

## ASK
**Questions to analyse:**
Three questions will guide the future marketing program: 
1.	How do annual members and casual riders use Cyclistic bikes differently? 
2.	Why would casual riders buy Cyclistic annual memberships? 
3.	How can Cyclistic use digital media to influence casual riders to become members?

**Identify the business task:**
Strategy to maximize the number of annual memberships by converting casual riders into annual riders.

**Consider key stakeholders:**
Lily Monero & the executive team

**Stakeholder perspective:**
Monero believes company’s future success depends on maximizing the number of annual memberships. She believes rather than creating a marketing campaign targeting all the new customers, there is a very good chance to convert casual riders into members. 

Need to build up strategy to convert casual riders into annual members through the help of data analysis.

## PREPARE
In this step, we prepare the data by obtaining the dataset and storing it. The datasets are given as a monthly based trip data in .zip files. The data I will be analysing will be of 12 months (i.e from December 2021 – November 2021). The data is reliable, free of any bias, and has been collected by cyclistic and stored on the company’s database separated by month in CSV format. 
The data collection team at Cyclistic have outlined some key facts about data:
1.	Each month contains every single trip that took place during that period.
2.	All personal customer information has been removed for privacy issues.
3.	Classic bikes were previously labelled ‘docked bikes’, they refer to same thing
4.	Classic bikes must start and end at a docking station, whereas electric bikes have a bike locked up anywhere in the general vicinity of a docking station.
5.	The data should not have no trips shorter than 1 minute or longer than 1 day. Any data that does not fit these constraints should be removed as it is a maintenance trip carried out by the Cyclistic team, or the bike has been stolen.

If you would like to explore the original data, the dataset can be found here.


## PROCESS
To combine the 12 csv files and clean the data, I used Microsoft SQL Server platform. Below is the outline of my process.
### IMPORTING AND COMBINING DATA
-	Created a dataset called “Cyclistic” and created a table called “Cyclistic_data” keeping column names same as that in the csv files provided, and using appropriate datatype.

  

-	Imported data from all the 12 csv files, using CURSOR and BULK INSERT statement resulting in all the data being combined into this one table I created above. The table contained 5,479,096 rows and 13 columns.

 

-	Added some new columns that might help me in further analysing the data. These columns were of ride_length (tell the duration of ride) and day_of_week (tell weekdays in numbers, starting from Sunday as 1 ending at Saturday as 7).

 

### PRE-CLEANING EXPLORATION
To know the data more, I ran queries on each column and made notes of the data that needs to be cleaned. My pre-cleaning data exploration process in MS SQL Server can be seen here on Github.
Following is a quick summary of my findings:-
1.	**ride_id:** it is the primary key, having no duplicates, and each id has exactly 16 characters, i.e they are same in length.
2.	**rideable_type:** the data contains three types of bikes- classic, docked, and electric. However, as specified by the data collection team, ‘docked bike’ is the old name for ‘classic bike’.
3.	**started_at/ended_at:** shows date and time of bike rides that started and ended. Although we only need rides greater than 1 minute and less than a day.
4.	**start_station_id/end_station_id:** these are of no use to us as of now, at do no harm. Therefore, they will remain as it is.
5.	**start_station_name/end_station_name:** as the name suggests, it contains station names of bike rides started and ended at. Rows having null values all together in start/end station names and ids will be removed.
6.	**start_lat/end_lat and start_lng/end_lng:** these contains starting and ending location of bike rides. Any null values in these columns will be removed as if a bike is taken for a ride it should have its starting and ending location.
7.	**member_casual:** this indicates whether the user of the bike is a casual user or an annual member. There are only two types in the column- ‘casual’ and ‘member’.



### CLEANING
After pre-cleaning process, I was aware of what data needs to be cleaned. The code for cleaning can be viewd from here. 
 
A Summary of data cleaning steps:
1.	Removed rows where start/end station names and start/end station ids were NULL.
2.	Removed rows having NULL values in start/end latitude and longitude columns, as start/end location of bike should be mentioned. 
3.	In total 401,836 rows were removed, and now the cleaned data was of 5,077,260 rows in total.

**Altering and Updating some new columns:**
Added some new columns that might help me in further analysing the data. These columns were of ride_length (tell the duration of ride) and day_of_week (tell weekdays in numbers, starting from Sunday as 1 ending at Saturday as 7).
 
## ANALYZE AND SHARE
After cleaning of the data, I started analysing it in MS SQL Server. I analysed it by sorting, filtering, and aggregating it before importing it to tableau to create visualizations. 
My SQL analysis can be viewed from here.
My tableau visualizations can be viewed from here.

Some examples of the queries can be seen below:
 
 
**Insights of Tableau Analysis**
A Summary of all the visuals from the Tableau: -
1.	Number of rides starts increasing from the month of April and the highest goes till July. It starts decreasing from August onwards and drops rapidly in November, and continues to drop till February, Feb having the lowest number of rides.
2.	Summers (Jun-Aug) is the season where there are highest number of rides seen by both type of riders (casual and members).
3.	The total trip duration for casual riders and annual members are affected by the season. The temperature is very low during the winter season, fewer people are willing to go out and people who need to travel daily for work will choose to take other public transport, this had caused the total trip duration are the lowest among another season.
4.	More than half (55%) number of total rides are taken by the annual members. This indicates that the company has already sustained a level of loyalty among their customers. Thus, the company may not face much difficulty in converting their casual riders to annual members.
5.	Casual bike riders tend to take longer hours of bike rides as compared to member bike riders. Approximately 70% of the total ride duration is of casuals, while 30% is of annual members.
6.	Casual bike riders are seen to take longer hours of rides on the Saturdays and Sundays. While the annual members are seen to be consistent bike riders throughout the week. More people (both casual and members) prefer classic bikes to ride over electric bike. 
7.	There is a high chance casual bike riders riding on weekends are tourists or families who are visiting the coastline for leisure activities such as sightseeing during the weekend.
8.	Afternoons, Evenings, and Mornings are the time of the weekdays where members take most number of rides as compared to casuals. Whereas afternoon time are the active hours for casual riders and there are more rides seen by them as compared to members.
9.	Annual members are mostly riders riding Cyclistic bikes for trips during weekdays maybe to get to work and casual riders ride more on weekends for leisure.

## ACT/RECOMMENDATIONS 
With the above knowledge of the differences between the two customer segments (casuals and annual members), I have brought up one potential issue below. The marketing department can start to develop its strategy of converting casual members to annual members.
Issue: A large percentage of the casual riders are most likely tourists visiting Chicago who cannot be converted into annual members.
The following are some recommendations from my side for the marketing team so that they can target at converting local residents who are casual members into long-term members:
1.	Based on the rides trend, marketing campaign should be launched between May to July, during the summers when the number of rides starts rising.
2.	Promotional banners and booths could be set up near some popular/famous starting and ending stations to attract more people.
3.	Casual riders usually ride more on the weekends, so to gain their subscription a weekend only membership can be launched in a lower price to attract them. 
4.	Membership can also be given based on the ride duration or length, which charges less as the ride duration increases. This will motivate casual riders to subscribe as they tend to ride long hours according to the visualization.
