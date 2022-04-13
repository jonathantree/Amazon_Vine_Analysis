-- Check the import of the vine table
SELECT * FROM vine_table
LIMIT 10;

/*
Filter the data and create a new DataFrame or table to 
retrieve all the rows where the total_votes count is 
equal to or greater than 20 to pick reviews that are 
more likely to be helpful and to avoid having division 
by zero errors later on.
*/
SELECT * 
INTO vine_highvotes
FROM vine_table
WHERE vine_table.total_votes > 20;

SELECT * FROM vine_highvotes
LIMIT 10;

/*
Filter the new DataFrame or table created in Step 1 and 
create a new DataFrame or table to retrieve all the rows 
where the number of helpful_votes divided by total_votes 
is equal to or greater than 50%.
*/

SELECT *
INTO vine_votes_gt50
FROM vine_highvotes
WHERE CAST(helpful_votes AS FLOAT)/CAST(total_votes AS FLOAT) >=0.5

SELECT * FROM vine_votes_gt50
LIMIT 10;

/*
Filter the DataFrame or table created in Step 2, 
and create a new DataFrame or table that retrieves 
all the rows where a review was written as part of the 
Vine program
*/

SELECT *
FROM vine_votes_gt50
WHERE vine_votes_gt50.vine = 'Y';

--Check to make sure there are no vine participants in the dataset

SELECT *
FROM vine_votes_gt50
ORDER BY vine_votes_gt50.vine DESC;

/*
Just for practice
Continue with analysis to check for bias as if we did have
vine participants 
*/
/*
Determine the total number of reviews, the number of 5-star 
reviews, and the percentage of 5-star reviews for the two 
types of review 
*/
--Create a summary table to populate with the data
CREATE TABLE Rating_Summary (
	Ratings_Count float,
	Total_Fives float,
	Percent_Fives FLOAT GENERATED ALWAYS AS (100*(Total_Fives/Ratings_Count)) STORED
);

-- Get the total number of ratings and store it in a table
SELECT COUNT(star_rating)
INTO rating_count
FROM vine_votes_gt50;

SELECT * FROM rating_count;

-- Get the total number of five-star ratings and store it in a table
SELECT COUNT(star_rating)
INTO five_star_count
FROM vine_votes_gt50
WHERE star_rating = 5;

SELECT * FROM five_star_count;

--Rename the columns to be able to cross-join them
ALTER TABLE rating_count
RENAME count TO "Total_Ratings";

ALTER TABLE five_star_count
RENAME count TO "Total_Fives";

--Join the count tables for populating the summary table
SELECT *
INTO rating_temp
FROM rating_count
CROSS JOIN five_star_count;

SELECT * FROM rating_temp;

-- Populate the summary table
INSERT INTO Rating_Summary (Ratings_Count, Total_Fives)
SELECT * FROM rating_temp;

SELECT * FROM Rating_Summary;



