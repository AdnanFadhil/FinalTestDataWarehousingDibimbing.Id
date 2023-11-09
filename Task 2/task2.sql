CREATE TABLE dim_user (
  user_id INT PRIMARY KEY,
  user_name VARCHAR(100),
  country VARCHAR(50)
);

INSERT INTO dim_user (user_id, user_name, country)
SELECT DISTINCT user_id, user_name, country
FROM raw_users;

CREATE TABLE dim_post (
  post_id INT PRIMARY KEY,
  post_text VARCHAR(500),
  post_date DATE,
  user_id INT REFERENCES dim_user(user_id)
);
INSERT INTO dim_post (post_id, post_text, post_date, user_id)
SELECT DISTINCT post_id, post_text, post_date, user_id
FROM raw_posts;

CREATE TABLE dim_date (
  date_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES dim_user(user_id),
  post_date DATE,
  like_date DATE
);

INSERT INTO dim_date (user_id, post_date, like_date)
SELECT DISTINCT user_id, post_date, like_date
FROM (
  SELECT user_id, post_date, NULL AS like_date FROM raw_posts
  UNION
  SELECT user_id, NULL AS post_date, like_date FROM raw_likes
) AS combined_dates;


CREATE TABLE fact_post_performance (
  post_id INT PRIMARY KEY REFERENCES dim_post(post_id),
  views INT,
  likes INT
);

INSERT INTO fact_post_performance (post_id, views, likes)
SELECT
  rp.post_id,
  COUNT(DISTINCT rp.post_id) AS views,
  (SELECT COUNT(*) FROM raw_likes WHERE post_id = rp.post_id) AS likes
FROM raw_posts rp
GROUP BY rp.post_id;



CREATE TABLE fact_daily_posts (
  daily_id SERIAL PRIMARY KEY,
  post_date DATE,
  posts_count INT
);

INSERT INTO fact_daily_posts (post_date, posts_count)
SELECT
  rp.post_date,
  COUNT(*) AS posts_count
FROM raw_posts rp
GROUP BY rp.post_date;
