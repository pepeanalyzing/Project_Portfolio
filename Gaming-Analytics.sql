CREATE DATABASE games;

CREATE TABLE games_description(
game_name VARCHAR(255),
game_id VARCHAR(20) PRIMARY KEY,	
year_released YEAR,	
publisher VARCHAR(100),	
genre VARCHAR(50)
);

CREATE TABLE games_revenue(
game_id VARCHAR(20),
Number_of_Purchases INT,
Unit_Price DECIMAL(10,2),
FOREIGN KEY (game_id) REFERENCES games_description (game_id)
);

CREATE TABLE games_reviews(
game_name VARCHAR(255),
game_id VARCHAR(20),
number_of_reviews_from_purchased_people INT,
number_of_english_reviews INT,
Hours_Played INT,
Helpful INT,
Funny INT,
FOREIGN KEY (game_id) REFERENCES games_description(game_id)
);

-- TASK 3
-- 1.1 Total revenue for each game.
SELECT 
	gd.game_name,
    gr.game_id,
    (gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue
FROM
	games_revenue gr
JOIN 
	games_description gd ON gd.game_id = gr.game_id
ORDER BY 
	total_revenue DESC;
    
    
-- 1.2 What are the top 5 games by revenue?
SELECT 
	gd.game_name,
    gr.game_id,   
    (gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue
FROM
	games_revenue gr
JOIN 
	games_description gd ON gd.game_id = gr.game_id
ORDER BY 
	total_revenue DESC
Limit 5;    


-- 1.3 Identify the top 3 genres by total revenue.
SELECT 
	gd.genre,
	SUM(gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue
FROM
	games_description gd
JOIN 
	games_revenue gr ON gd.game_id = gr.game_id
GROUP BY
	gd.genre		
ORDER BY 
	total_revenue DESC
Limit 3;


-- 1.4 Which year generated most of the revenue in the company?
SELECT 
	gd.year_released AS year,
	SUM(gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue
FROM
	games_description gd
JOIN 
	games_revenue gr ON gd.game_id = gr.game_id
GROUP BY
	gd.year_released		
ORDER BY 
	total_revenue DESC
LIMIT 1;

-- 2. Calculate the percentage of customers who left reviews out of the total purchase
SELECT 
	gd.game_name,
    grv.game_id, 
    grv.number_of_reviews_from_purchased_people AS total_buyer_reviews,
    gr.Number_of_Purchases AS total_purchases,
    ROUND(grv.number_of_reviews_from_purchased_people/gr.Number_of_Purchases*100,2) 
    AS review_rate_pct 
FROM
	games_description gd
JOIN
	games_revenue gr ON gd.game_id = gr.game_id
JOIN
	games_reviews grv ON gd.game_id = grv.game_id
ORDER BY
	review_rate_pct DESC;
	
-- 3. Determine the percentage of reviews written in English for each game
SELECT
	gd.game_name,
    grv.game_id,
    grv.number_of_english_reviews AS english_reviews,
    grv.number_of_reviews_from_purchased_people AS total_buyer_reviews,
    ROUND(grv.number_of_english_reviews/grv.number_of_reviews_from_purchased_people*100,2) 
    AS english_review_pct
FROM
	games_reviews grv
JOIN 
	games_description gd ON gd.game_id = grv.game_id
ORDER BY
	english_review_pct DESC;
    

-- 4. Find the top 5 publishers by total revenue.
SELECT
	gd.publisher,
    SUM(gr.Number_of_Purchases * gr.Unit_Price) AS total_revenue
FROM
	games_description gd
JOIN 
	games_revenue gr ON gd.game_id = gr.game_id
GROUP BY
	gd.publisher		
ORDER BY 
	total_revenue DESC
Limit 5;


-- 5.1 Calculate the percentage of Helpful and Funny tags to total reviews. 
SELECT
	gd.game_name,
    gd.genre,
    grv.Helpful,
    grv.Funny,
    grv.number_of_reviews_from_purchased_people AS total_buyer_reviews,
    ROUND(grv.Helpful/grv.number_of_reviews_from_purchased_people*100,2) AS helpful_pct,
    ROUND(grv.Funny/grv.number_of_reviews_from_purchased_people*100,2) AS funny_pct
FROM
	games_reviews grv
JOIN
	games_description gd ON gd.game_id = grv.game_id
ORDER BY
	helpful_pct DESC;
    
-- 5.2	Which games and genres have the highest and lowest percentages?
-- genre with helpful desc
SELECT
	gd.genre,    
    ROUND(SUM(grv.Helpful)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS helpful_pct,
    ROUND(SUM(grv.Funny)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS funny_pct
FROM
	games_reviews grv
JOIN
	games_description gd ON gd.game_id = grv.game_id
GROUP BY
	gd.genre
ORDER BY
	helpful_pct DESC;
    
-- genre with funny desc
SELECT
	gd.genre,    
    ROUND(SUM(grv.Helpful)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS helpful_pct,
    ROUND(SUM(grv.Funny)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS funny_pct
FROM
	games_reviews grv
JOIN
	games_description gd ON gd.game_id = grv.game_id
GROUP BY
	gd.genre
ORDER BY
	funny_pct DESC;
    
-- games with helpful desc
SELECT
	gd.game_name,    
    ROUND(SUM(grv.Helpful)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS helpful_pct,
    ROUND(SUM(grv.Funny)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS funny_pct
FROM
	games_reviews grv
JOIN
	games_description gd ON gd.game_id = grv.game_id
GROUP BY
	gd.game_name
ORDER BY
	helpful_pct DESC;
    
-- games with funny desc
SELECT
	gd.game_name,    
    ROUND(SUM(grv.Helpful)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS helpful_pct,
    ROUND(SUM(grv.Funny)/SUM(grv.number_of_reviews_from_purchased_people)*100,2) AS funny_pct
FROM
	games_reviews grv
JOIN
	games_description gd ON gd.game_id = grv.game_id
GROUP BY
	gd.game_name
ORDER BY
	funny_pct DESC;

    
-- TASK 4
-- 4.1 Rank games by their total revenue within each genre.
SELECT
	gd.genre,
    gd.game_name,
	(gr.number_of_purchases * gr.unit_price) AS total_revenue,
    RANK() OVER(PARTITION BY gd.genre ORDER BY (gr.number_of_purchases * gr.unit_price) DESC)
	AS genre_rank_by_revenue
FROM 
	games_description gd
JOIN 
	games_revenue gr ON gr.game_id = gd.game_id;
    

-- 4.2 Rank games by their total reviews within each genre.
SELECT 	
	gd.genre,
    gd.game_name,
    grv.number_of_reviews_from_purchased_people AS total_buyer_reviews,
    RANK() OVER(PARTITION BY gd.genre ORDER BY grv.number_of_reviews_from_purchased_people DESC) 
    AS genre_rank_by_reviews
FROM
	games_description gd
JOIN 
	games_reviews grv ON grv.game_id = gd.game_id;
    
