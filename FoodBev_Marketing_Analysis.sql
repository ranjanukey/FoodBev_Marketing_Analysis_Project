CREATE DATABASE SurveyDB;
USE SurveyDB;


SELECT * FROM dim_cities LIMIT 10;
SELECT * FROM dim_repondents LIMIT 10;
SELECT * FROM fact_survey_responses LIMIT 10;


USE SurveyDB;
SHOW TABLES;

SHOW TABLES;dim_respondents
SELECT * FROM dim_respondents LIMIT 10;

CREATE TABLE dim_respondents (
    Respondent_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    Age_Group VARCHAR(20),
    Gender VARCHAR(20),
    City_ID INT
);


#Query 1
# Who prefers energy drink more? (male/female/non-binary)
WITH CTE AS (
    SELECT 
        CASE WHEN Gender = 'Male' THEN 1 ELSE 0 END AS Total_Male,
        CASE WHEN Gender = 'Female' THEN 1 ELSE 0 END AS Total_Female,
        CASE WHEN Gender = 'Non-binary' THEN 1 ELSE 0 END AS Total_Non_binary
    FROM dim_repondents
)
SELECT Age,
    SUM(Total_Male) AS Total_Males,
    SUM(Total_Female) AS Total_Females,
    SUM(Total_Non_binary) AS Total_Non_binary
FROM CTE;

DESCRIBE dim_repondents;

# Q1. Demographic Insights

SELECT * FROM dim_cities LIMIT 10;
SELECT * FROM dim_repondents LIMIT 10;
SELECT * FROM fact_survey_responses LIMIT 10;
###########################################################################################################################################
select * from dim_cities;
select * from dim_respondents;
select * from fact_survey_responses;

#normal_join between dim_respondents and fact_survey_respondents table
SELECT *
FROM dim_respondents a 
join fact_survey_responses b 
on a.Respondent_ID = b.Respondent_ID;

#1. Who prefers energy drink more? (male/female/non-binary?)
SELECT a.Gender, count(b.Consume_frequency) Times_Preferred
FROM dim_respondents a 
join fact_survey_responses b 
on a.Respondent_ID = b.Respondent_ID 
where b.Consume_frequency <> 'Rarely'
group by a.Gender
order by count(b.Consume_frequency) desc;

#2. Which age group prefers energy drinks more?
SELECT a.Age AS Age_Group, 
       COUNT(b.Consume_frequency) AS Times_Preferred
FROM dim_respondents a 
JOIN fact_survey_responses b 
ON a.Respondent_ID = b.Respondent_ID 
GROUP BY a.Age
ORDER BY COUNT(b.Consume_frequency) DESC;

# times preferred by 15-18 age group
SELECT a.Age AS Age_Group, 
       COUNT(b.Consume_frequency) AS Times_Preferred
FROM dim_respondents a 
JOIN fact_survey_responses b 
ON a.Respondent_ID = b.Respondent_ID 
WHERE b.Consume_frequency <> 'Rarely' 
  AND a.Age = '15-18'
GROUP BY a.Age
ORDER BY COUNT(b.Consume_frequency) DESC;

select count(Age) from dim_respondents
where Age = '15-18';

#3. Which type of marketing reaches the most Youth (15-30)?
SELECT b.Marketing_channels AS Marketing_Channel, 
       COUNT(b.Marketing_channels) AS Occurrence
FROM dim_respondents a 
JOIN fact_survey_responses b 
ON a.Respondent_ID = b.Respondent_ID 
WHERE a.Age BETWEEN 15 AND 30  -- Corrected age range filtering
GROUP BY b.Marketing_channels
ORDER BY COUNT(b.Marketing_channels) DESC;

##########################################################################################################################################
# Q2. Consumer Preferences

select * from dim_cities;
select * from dim_respondents;
select * from fact_survey_responses;

#a. What are the preferred ingredients of energy drinks among respondents?
select Ingredients_expected Ingredients, count(Ingredients_expected) Times_Consumed
from fact_survey_responses
group by Ingredients_expected
order by count(Ingredients_expected) desc;

#b. What packaging preferences do respondents have for energy drinks?

############################################################################################################################################

# Q3. Competition Analysis

select * from dim_cities;
select * from dim_respondents;
select * from fact_survey_responses;

# Who are the current market leaders?
select Current_brands, count(Current_brands) Sales_among_10000_respondents
from fact_survey_responses
group by Current_brands
order by count(Current_brands) desc;

# What are the primary reasons consumers prefer those brands over ours?
select Current_brands from fact_survey_responses where
(select Current_brands, Reasons_for_choosing_brands, count(Reasons_for_choosing_brands)
from fact_survey_responses
group by Reasons_for_choosing_brands
order by count(Reasons_for_choosing_brands) desc);

############################################################################################################################################

# Q4. Marketing Channels and Brand Awareness:

select * from dim_cities;
select * from dim_respondents;
select * from fact_survey_responses;

#a. Which marketing channel can be used to reach more customers?
select Marketing_channels, 
	count(Marketing_channels) Times_reached_among_10000_consumers
from fact_survey_responses
group by Marketing_channels
order by count(Marketing_channels) desc;

#*b. How effective are different marketing strategies and channels in reaching our customers?*/

select Marketing_channels, count(Marketing_channels) Times_reached_among_980_CodeX_consumers
from fact_survey_responses
where Current_brands = 'CodeX'
group by Marketing_channels
order by count(Marketing_channels) desc;

#based_on_limited_edition_packaging_strategy
select Limited_edition_packaging, count(Limited_edition_packaging) Times_reached_among_980_consumers
from fact_survey_responses
where Current_brands = 'CodeX'
group by Limited_edition_packaging
order by count(Limited_edition_packaging) desc;

##########################################################################################################################

# Q5. Brand Penetration:


#a. What do people think about our brand? (overall rating)
select General_perception, count(General_perception) 
from fact_survey_responses
where Current_brands = 'CodeX'
group by General_perception
order by count(General_perception) desc;

#brand_perception
select Brand_perception, count(Brand_perception) Consumer_Rating
from fact_survey_responses
where Current_brands = 'CodeX'
group by Brand_perception
order by count(Brand_perception) desc;

#b. Which cities do we need to focus more on?
SELECT b.City, count(b.City) Sales
FROM dim_respondents a 
join dim_cities b 
on a.City_ID = b.City_ID 
join fact_survey_responses c
on  a.Respondent_ID = c.Respondent_ID
where c.Current_brands = 'CodeX'
group by b.City
order by count(b.City);

##########################################################################################################################
# Q6. Purchase Behavior:
select * from fact_survey_responses;

#a. Where do respondents prefer to purchase energy drinks?
select Purchase_location, count(Purchase_location) Times_Purchased
from fact_survey_responses
group by Purchase_location
order by count(Purchase_location) desc;

/*b. What are the typical consumption situations for energy drinks among 
respondents?*/
select Typical_consumption_situations, count(Typical_consumption_situations) Number_of_times
from fact_survey_responses
group by Typical_consumption_situations
order by count(Typical_consumption_situations) desc;


/*c. What factors influence respondents' purchase decisions, such as price range and limited edition packaging?*/
SELECT Price_range, 
    COUNT(*) AS Number_of_times
FROM fact_survey_responses
GROUP BY Price_range
ORDER BY Number_of_times DESC;

select Limited_edition_packaging, count(Limited_edition_packaging) Number_of_times
from fact_survey_responses
group by Limited_edition_packaging
order by count(Limited_edition_packaging) desc;
###########################################################################################################################
# Q7. Product Development

/*a. Which area of business should we focus more on our product development? 
(Branding/taste/availability)*/
select Reasons_for_choosing_brands, count(Reasons_for_choosing_brands) Number_of_times
from fact_survey_responses
where Current_brands = 'CodeX' and Reasons_for_choosing_brands not in ('Other', 'Effectiveness')
group by Reasons_for_choosing_brands
order by count(Reasons_for_choosing_brands);

select Reasons_preventing_trying, count(Reasons_preventing_trying)
from fact_survey_responses
where Current_brands = 'CodeX'
group by Reasons_preventing_trying
order by count(Reasons_preventing_trying) desc;