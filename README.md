# Amazon Vine Analysis

## Project Overview
The Amazon Vine program is a service that allows manufacturers and publishers to receive reviews for their products. Companies pay a small fee to Amazon and provide products to Amazon Vine members, who are then required to publish a review. The purpose of this project was to analyze one of the [Amazon Reviews](https://s3.amazonaws.com/amazon-reviews-pds/tsv/index.txt) datasets to determine if there is any bias toward favorable reviews from Vine members. The approach was to create an AWS RDS database in pgAdmin, use PySpark and Google Colab to perform ETL on the chosen dataset and upload the final dataframes into the tables of pgAdmin. Once the database was populated, analysis on the reviews was conducted to determine the total number of reviews, the number of 5-star reviews, and the percentage of 5-star reviews for the two types of review (paid vs unpaid). This analysis was first conducted in pgAdmin only to find out that the chosen dataset did not contain any Vine participants (dataset: mobile apps). A new dataset was chosen and the analysis was replicated using PySpark (dataset: pet products). Both are presented here for thoroughness but final results were only obtained from the PySpark analysis. These results are presented first.

## PySpark Results

### Paid (Vine Participants) *See the dataframes generated below*
- The number of total reviews in the pet products dataset was 162.
- The number of 5-star reviews was 63.
- The percentage of the reviews that are 5-star was 38.89%

### Unpaid (Non-Vine Participants) *See the dataframes generated below*
- The number of total reviews in the pet products dataset was 35,606.
- The number of 5-star reviews was 19,444.
- The percentage of the reviews that are 5-star was 54.61%

## Summary
This analysis revealed that there is no positive bias for reviews in the Vine program for Pet Products. The percentage of 5 star reviews for the Vine participating products was 15.72% lower than those who did not participate. This would suggest that participating in the Vine program does not generate a more positive outcome in the reviews for these specific product. 

#### Further Analysis
This analysis only considered 5 star reviews as a bias indicator. Another approach could use the entire distribution to consider whether or not participating in the Vine program would generate a higher review on average (not just a 5-star review). A simple two-sample t-test of the mean reviews of the paid vs unpaid would reveal the statistical significance of the difference of the two subsets of data. This test would be able to establish using the entire distribution of reviews whether or not the Vine participants, on average, received a higher rating than those who are not participating in the program.

This analysis could also benefit from further investigation by re-running the analysis on only those reviews with a verified purchase to see if a verified purchase review change anything.

### Code:
### Load Amazon Data -> Create DataFrame


```python
from pyspark.sql import SparkSession
spark = SparkSession.builder.appName("M16-Amazon-Challenge").config("spark.driver.extraClassPath","/content/postgresql-42.2.16.jar").getOrCreate()
from pyspark.sql.functions import to_date
# Read in the Review dataset as a DataFrame
from pyspark import SparkFiles
url = "https://s3.amazonaws.com/amazon-reviews-pds/tsv/amazon_reviews_us_Pet_Products_v1_00.tsv.gz"
spark.sparkContext.addFile(url)
reviews_df = spark.read.option("encoding", "UTF-8").csv(SparkFiles.get(""), sep="\t", header=True, inferSchema=True)
reviews_df.show()
```

    +-----------+-----------+--------------+----------+--------------+--------------------+----------------+-----------+-------------+-----------+----+-----------------+--------------------+--------------------+-----------+
    |marketplace|customer_id|     review_id|product_id|product_parent|       product_title|product_category|star_rating|helpful_votes|total_votes|vine|verified_purchase|     review_headline|         review_body|review_date|
    +-----------+-----------+--------------+----------+--------------+--------------------+----------------+-----------+-------------+-----------+----+-----------------+--------------------+--------------------+-----------+
    |         US|   28794885| REAKC26P07MDN|B00Q0K9604|     510387886|(8-Pack) EZwhelp ...|    Pet Products|          5|            0|          0|   N|                Y|A great purchase ...|Best belly bands ...| 2015-08-31|
    |         US|   11488901|R3NU7OMZ4HQIEG|B00MBW5O9W|     912374672|Warren Eckstein's...|    Pet Products|          2|            0|          1|   N|                Y|My dogs love Hugs...|My dogs love Hugs...| 2015-08-31|
    |         US|   43214993|R14QJW3XF8QO1P|B0084OHUIO|     902215727|Tyson's True Chew...|    Pet Products|          5|            0|          0|   N|                Y|I have been purch...|I have been purch...| 2015-08-31|
    |         US|   12835065|R2HB7AX0394ZGY|B001GS71K2|     568880110|Soft Side Pet Cra...|    Pet Products|          5|            0|          0|   N|                Y|it is easy to ope...|It is extremely w...| 2015-08-31|
    |         US|   26334022| RGKMPDQGSAHR3|B004ABH1LG|     692846826|EliteField 3-Door...|    Pet Products|          5|            0|          0|   N|                Y|           Dog crate|Worked really wel...| 2015-08-31|
    |         US|   22283621|R1DJCVPQGCV66E|B00AX0LFM4|     590674141|Carlson 68-Inch W...|    Pet Products|          5|            0|          0|   N|                Y|          Five Stars|I love my gates! ...| 2015-08-31|
    |         US|   14469895|R3V52EAWLPBFQG|B00DQFZGZ0|     688538603|Dog Seat Cover Wi...|    Pet Products|          3|            0|          0|   N|                Y|Seat belt tugs on...|Didn't quite work...| 2015-08-31|
    |         US|   50896354|R3DKO8J1J28QBI|B00DIRF9US|     742358789|The Bird Catcher ...|    Pet Products|          2|            0|          0|   N|                Y|Great Pole, but S...|I had the origina...| 2015-08-31|
    |         US|   18440567| R764DBXGRNECG|B00JRCBFUG|     869798483|Cat Bed - Purrfec...|    Pet Products|          5|            1|          1|   N|                N|     My cat loves it|The pad is very s...| 2015-08-31|
    |         US|   50502362| RW1853GAT0Z9F|B000L3XYZ4|     501118658|PetSafe Drinkwell...|    Pet Products|          5|            0|          0|   N|                Y|          Five Stars|My cat drinks mor...| 2015-08-31|
    |         US|   33930128|R33GITXNUF1AD4|B00BOEXWFG|     454737777|Contech ZenDog Ca...|    Pet Products|          2|            0|          0|   N|                Y|Also had to pull ...|Much smaller than...| 2015-08-31|
    |         US|   43534290|R1H7AVM81TAYRV|B001HBBQKY|     420905252|Wellness Crunchy ...|    Pet Products|          1|            2|          2|   N|                Y|DO NOT PURCHASE -...|I used to love th...| 2015-08-31|
    |         US|   45555864|R2ZOYAQZNNZZWV|B007O1FHB0|     302588963|Rx Vitamins Essen...|    Pet Products|          5|            0|          0|   N|                Y|          Five Stars|Recommended by my...| 2015-08-31|
    |         US|   11147406|R2FN1H3CGW6J8H|B001P3NU30|     525778264|Virbac C.E.T. Enz...|    Pet Products|          1|            0|          0|   N|                Y|Received wrong pr...|Yes I  ordered fo...| 2015-08-31|
    |         US|    6495678| RJB41Q575XNG4|B00ZP6HS6S|     414117299|Kitty Shack - 2 i...|    Pet Products|          5|            0|          3|   N|                Y|          Five Stars|      It falls apart| 2015-08-31|
    |         US|    2019416|R28W8BM1587CPF|B00IP05CUA|     833937853|Wellness Kittles ...|    Pet Products|          5|            0|          0|   N|                Y|kitty is ravenous...|My cat really lov...| 2015-08-31|
    |         US|   40459386|R1II0M01NIG293|B001U8Y598|      85343577|OmniPet Anti-Ant ...|    Pet Products|          2|            0|          0|   N|                N|Maybe other speci...|This bowl is not ...| 2015-08-31|
    |         US|   23126800| RMB8N0DBRH34O|B011AY4JWO|     499241195|K9KONNECTION [New...|    Pet Products|          5|            1|          1|   N|                Y|This works, dog n...|I have a small do...| 2015-08-31|
    |         US|   30238476|R24WB6A6WVIPU6|B00DDSHE5A|     409532388|SUNSEED COMPANY 3...|    Pet Products|          5|            0|          0|   N|                Y|    Yummy for Bunny!|Bunny loves it! E...| 2015-08-31|
    |         US|   35113999| ROCJSH0P9YSRW|B00PJW5OR8|     259271919|CXB1983(TM)Cute P...|    Pet Products|          5|            0|          0|   N|                Y|excellent price, ...|Petfect,,quality ...| 2015-08-31|
    +-----------+-----------+--------------+----------+--------------+--------------------+----------------+-----------+-------------+-----------+----+-----------------+--------------------+--------------------+-----------+
    only showing top 20 rows
    
    


```python
# Create the vine_table. DataFrame
vine_df = reviews_df.select(["review_id", "star_rating", "helpful_votes", "total_votes", "vine", "verified_purchase"])
vine_df.show()
```

    +--------------+-----------+-------------+-----------+----+-----------------+
    |     review_id|star_rating|helpful_votes|total_votes|vine|verified_purchase|
    +--------------+-----------+-------------+-----------+----+-----------------+
    | REAKC26P07MDN|          5|            0|          0|   N|                Y|
    |R3NU7OMZ4HQIEG|          2|            0|          1|   N|                Y|
    |R14QJW3XF8QO1P|          5|            0|          0|   N|                Y|
    |R2HB7AX0394ZGY|          5|            0|          0|   N|                Y|
    | RGKMPDQGSAHR3|          5|            0|          0|   N|                Y|
    |R1DJCVPQGCV66E|          5|            0|          0|   N|                Y|
    |R3V52EAWLPBFQG|          3|            0|          0|   N|                Y|
    |R3DKO8J1J28QBI|          2|            0|          0|   N|                Y|
    | R764DBXGRNECG|          5|            1|          1|   N|                N|
    | RW1853GAT0Z9F|          5|            0|          0|   N|                Y|
    |R33GITXNUF1AD4|          2|            0|          0|   N|                Y|
    |R1H7AVM81TAYRV|          1|            2|          2|   N|                Y|
    |R2ZOYAQZNNZZWV|          5|            0|          0|   N|                Y|
    |R2FN1H3CGW6J8H|          1|            0|          0|   N|                Y|
    | RJB41Q575XNG4|          5|            0|          3|   N|                Y|
    |R28W8BM1587CPF|          5|            0|          0|   N|                Y|
    |R1II0M01NIG293|          2|            0|          0|   N|                N|
    | RMB8N0DBRH34O|          5|            1|          1|   N|                Y|
    |R24WB6A6WVIPU6|          5|            0|          0|   N|                Y|
    | ROCJSH0P9YSRW|          5|            0|          0|   N|                Y|
    +--------------+-----------+-------------+-----------+----+-----------------+
    only showing top 20 rows
    
    


```python
from pyspark.sql.functions import count

```


```python
# Filter the data and create a new DataFrame or table to retrieve all the rows where the total_votes count is equal to or greater than 20
gt20_df = vine_df.filter("total_votes > 20")
gt20_df.show()
```

    +--------------+-----------+-------------+-----------+----+-----------------+
    |     review_id|star_rating|helpful_votes|total_votes|vine|verified_purchase|
    +--------------+-----------+-------------+-----------+----+-----------------+
    |R21KC552Y6HL8X|          1|           27|         31|   N|                Y|
    | RX9WC9FTIR1XR|          5|           25|         25|   N|                Y|
    | RGDCOU1KBHMNG|          3|           29|         31|   N|                Y|
    | RVTYWID2TPMMY|          2|           35|         42|   N|                Y|
    |R2CMPZ5VESGRLY|          4|           27|         28|   N|                Y|
    |R3VQPJZ54B55BA|          5|           62|         64|   N|                N|
    |R24QM6D7FEDZ5M|          2|           36|         43|   N|                Y|
    |  R39GSNW76GYF|          1|           20|         23|   N|                Y|
    | RPJLR6MFDPXXE|          5|           35|         36|   N|                Y|
    |R34X0ZGVB3YGYO|          5|           47|         47|   N|                Y|
    |R2C9O1BOV14Q0Z|          1|           62|         79|   N|                Y|
    | RM6ZH5J3XDNHK|          5|           79|         87|   N|                Y|
    |R2E363K75EMW4K|          5|           66|         69|   N|                Y|
    |R2VJII8VKSJHDF|          1|           24|         29|   N|                N|
    |R2U35Y2P27M13E|          1|           43|         45|   N|                Y|
    | RLMZOQL11VHBX|          5|           23|         24|   N|                Y|
    |R3C6CQQRRA8SYP|          5|           52|         58|   N|                Y|
    |R3T7YOX0AEDZL3|          1|           45|         47|   N|                N|
    |R176V3AYS3R4HG|          5|           26|         27|   N|                N|
    |R1E5UU8JBUSHU2|          5|           29|         29|   N|                Y|
    +--------------+-----------+-------------+-----------+----+-----------------+
    only showing top 20 rows
    
    


```python
# Filter to retrieve all the rows where the number of helpful_votes divided by total_votes is equal to or greater than 50%
helpful_df = gt20_df.filter(gt20_df.helpful_votes/gt20_df.total_votes >= 0.50)
helpful_df.show()
```

    +--------------+-----------+-------------+-----------+----+-----------------+
    |     review_id|star_rating|helpful_votes|total_votes|vine|verified_purchase|
    +--------------+-----------+-------------+-----------+----+-----------------+
    |R21KC552Y6HL8X|          1|           27|         31|   N|                Y|
    | RX9WC9FTIR1XR|          5|           25|         25|   N|                Y|
    | RGDCOU1KBHMNG|          3|           29|         31|   N|                Y|
    | RVTYWID2TPMMY|          2|           35|         42|   N|                Y|
    |R2CMPZ5VESGRLY|          4|           27|         28|   N|                Y|
    |R3VQPJZ54B55BA|          5|           62|         64|   N|                N|
    |R24QM6D7FEDZ5M|          2|           36|         43|   N|                Y|
    |  R39GSNW76GYF|          1|           20|         23|   N|                Y|
    | RPJLR6MFDPXXE|          5|           35|         36|   N|                Y|
    |R34X0ZGVB3YGYO|          5|           47|         47|   N|                Y|
    |R2C9O1BOV14Q0Z|          1|           62|         79|   N|                Y|
    | RM6ZH5J3XDNHK|          5|           79|         87|   N|                Y|
    |R2E363K75EMW4K|          5|           66|         69|   N|                Y|
    |R2VJII8VKSJHDF|          1|           24|         29|   N|                N|
    |R2U35Y2P27M13E|          1|           43|         45|   N|                Y|
    | RLMZOQL11VHBX|          5|           23|         24|   N|                Y|
    |R3C6CQQRRA8SYP|          5|           52|         58|   N|                Y|
    |R3T7YOX0AEDZL3|          1|           45|         47|   N|                N|
    |R176V3AYS3R4HG|          5|           26|         27|   N|                N|
    |R1E5UU8JBUSHU2|          5|           29|         29|   N|                Y|
    +--------------+-----------+-------------+-----------+----+-----------------+
    only showing top 20 rows
    
    35768
    


```python
# Filter previous DF for vine participants
vine_participants_df = helpful_df.filter("vine == 'Y'")
vine_participants_df.show()
```

    +--------------+-----------+-------------+-----------+----+-----------------+
    |     review_id|star_rating|helpful_votes|total_votes|vine|verified_purchase|
    +--------------+-----------+-------------+-----------+----+-----------------+
    |R3A71VR1JZD8WF|          2|           27|         30|   Y|                N|
    |R16OMUJIGI18JZ|          5|           72|         72|   Y|                N|
    |R3TS8ZP2FHQ9XR|          5|           39|         42|   Y|                N|
    |R2MHP919VZN7DI|          5|           29|         30|   Y|                N|
    |R1JUJLXQ2CMWKF|          4|           25|         26|   Y|                N|
    |R2T7YE0IFI6N9L|          3|           24|         25|   Y|                N|
    |R25FI3J7WWOYXM|          3|           55|         58|   Y|                N|
    |R3P3U4EOWIUD50|          3|           27|         36|   Y|                N|
    |R3C7MKX7MO6XUC|          5|          216|        219|   Y|                N|
    |R1DFDDK1ZWKN3D|          2|           61|         65|   Y|                N|
    |R38G7BRBA2LGGV|          3|           47|         54|   Y|                N|
    |R2XQXWNEBSB9WO|          4|           52|         56|   Y|                N|
    |R1UFK241B2KN48|          4|          375|        378|   Y|                N|
    |R3H9CGK58BVHI5|          4|           42|         46|   Y|                N|
    |R3NSXBUR3O1CE8|          5|           21|         22|   Y|                N|
    |R13JI50KH7BTBU|          4|           29|         30|   Y|                N|
    |R2LWQUQ6KB5ZN5|          4|           29|         36|   Y|                Y|
    |R1JORBU2J7HG3H|          5|           22|         25|   Y|                N|
    |R3F6KXGIFXQ3B6|          4|           40|         43|   Y|                N|
    |R3ANHBYBW9IPWD|          4|           35|         39|   Y|                N|
    +--------------+-----------+-------------+-----------+----+-----------------+
    only showing top 20 rows
    
    


```python
# Filter helpful_df for non-vine participants
no_vine_participants_df = helpful_df.filter("vine == 'N'")
no_vine_participants_df.show()
```

    +--------------+-----------+-------------+-----------+----+-----------------+
    |     review_id|star_rating|helpful_votes|total_votes|vine|verified_purchase|
    +--------------+-----------+-------------+-----------+----+-----------------+
    |R21KC552Y6HL8X|          1|           27|         31|   N|                Y|
    | RX9WC9FTIR1XR|          5|           25|         25|   N|                Y|
    | RGDCOU1KBHMNG|          3|           29|         31|   N|                Y|
    | RVTYWID2TPMMY|          2|           35|         42|   N|                Y|
    |R2CMPZ5VESGRLY|          4|           27|         28|   N|                Y|
    |R3VQPJZ54B55BA|          5|           62|         64|   N|                N|
    |R24QM6D7FEDZ5M|          2|           36|         43|   N|                Y|
    |  R39GSNW76GYF|          1|           20|         23|   N|                Y|
    | RPJLR6MFDPXXE|          5|           35|         36|   N|                Y|
    |R34X0ZGVB3YGYO|          5|           47|         47|   N|                Y|
    |R2C9O1BOV14Q0Z|          1|           62|         79|   N|                Y|
    | RM6ZH5J3XDNHK|          5|           79|         87|   N|                Y|
    |R2E363K75EMW4K|          5|           66|         69|   N|                Y|
    |R2VJII8VKSJHDF|          1|           24|         29|   N|                N|
    |R2U35Y2P27M13E|          1|           43|         45|   N|                Y|
    | RLMZOQL11VHBX|          5|           23|         24|   N|                Y|
    |R3C6CQQRRA8SYP|          5|           52|         58|   N|                Y|
    |R3T7YOX0AEDZL3|          1|           45|         47|   N|                N|
    |R176V3AYS3R4HG|          5|           26|         27|   N|                N|
    |R1E5UU8JBUSHU2|          5|           29|         29|   N|                Y|
    +--------------+-----------+-------------+-----------+----+-----------------+
    only showing top 20 rows
    
    


```python
# Vine participant analysis
vine_total_reviews = vine_participants_df.count()
vine_fivestars = vine_participants_df.filter("star_rating = 5").count()
vine_percent = 100*(vine_fivestars/vine_total_reviews)
print(f'Total reviews: {vine_total_reviews} , 5 star reviews: {vine_fivestars}')
print(f'The percentage of reviews from vine participants that are 5 stars is {vine_percent:.2f}%')
```

    Total reviews: 162 , 5 star reviews: 63
    The percentage of reviews from vine participants that are 5 stars is 38.89%
    


```python
# Non-Vine participant analysis
no_vine_total_reviews = no_vine_participants_df.count()
no_vine_fivestars = no_vine_participants_df.filter("star_rating = 5").count()
no_vine_percent = 100*(no_vine_fivestars/no_vine_total_reviews)
print(f'Total reviews: {no_vine_total_reviews} , 5 star reviews: {no_vine_fivestars}')
print(f'The percentage of reviews from non-vine participants that are 5 stars is {no_vine_percent:.2f}%')
```

    Total reviews: 35606 , 5 star reviews: 19444
    The percentage of reviews from non-vine participants that are 5 stars is 54.61%

## PostgreSQL Database and Query Analysis on the mobile app dataset

## Screenshot of the Vine Table

![vine table](/Images/PostgreSQL/vine_table.png)

### Analysis
```sql
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
```
![greater than 20 votes](/Images/PostgreSQL/gt_20.png)

```sql
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
```
![50% helpful](/Images/PostgreSQL/helpful_votes_gt50%.png)

## This is where we find out that there are actually no Vine participants in this dataset

```sql
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
```
![no vine](/Images/PostgreSQL/no_vine.png)
![no vine](/Images/PostgreSQL/no_vine_verification.png)

## Finish at least one half of the analysis
```sql
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
```
![Votes Summary](/Images/PostgreSQL/percent_5_votes.png)
