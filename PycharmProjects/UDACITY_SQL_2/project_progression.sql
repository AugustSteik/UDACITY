
-- navigating existing schema:
--SELECT COUNT(title) FROM bad_posts; = 50000
--SELECT DISTINCT COUNT(title) FROM bad_posts; = 50000

-- All titles unique.

--UPDATE bad_posts (title)
--INSERT INTO posts (title, text_content, url) SELECT title, text_content, url FROM bad_posts;


--CREATE TABLE user_downvotes_temp (
--    "user_idd" BIGINT,
--    "user_name" VARCHAR(100),
--    "post_id" BIGINT
--    );
--
--CREATE TABLE  user_upvotes_temp (
--    "user_idd" BIGINT,
--    "user_name" VARCHAR(100),
--    "post_id" BIGINT
--    );

---------------------------------------------------------------------------------------
-- Splitting up the votes


--INSERT INTO user_downvotes_temp (user_name, post_id)
--SELECT LEFT(downvotes, STRPOS(downvotes,',') -1), id FROM bad_posts
--WHERE downvotes IS NOT NULL;
--
--INSERT INTO user_downvotes_temp (user_name, post_id)
--SELECT RIGHT ( downvotes, STRPOS ( downvotes, ',') +1), id FROM bad_posts
--WHERE downvotes IS NOT NULL;
--
--INSERT INTO user_upvotes_temp (user_name, post_id)
--SELECT LEFT ( upvotes, STRPOS ( upvotes, ',') -1), id FROM bad_posts
--WHERE upvotes IS NOT NULL;
--
--INSERT INTO user_upvotes_temp (user_name, post_id)
--SELECT RIGHT ( upvotes, STRPOS ( upvotes, ',') +1), id FROM bad_posts
--WHERE upvotes IS NOT NULL;
--
--UPDATE user_downvotes_temp SET user_idd =
----    (
----        SELECT u.id
----        FROM users u
----        JOIN user_downvotes_temp udt
----        ON u.username = udt.user_name
------        LIMIT 1
----    )
--WHERE u.username = udt.user_name
--;
--
--UPDATE user_downvotes_temp udt
--JOIN users u ON u.username = udt.
--
--INSERT INTO votes (user_id, post_id)
--SELECT user_idd, post_id
--FROM user_downvotes_temp
--CASE WHEN user_idd IS NOT NULL THEN vote = -1;
--
--INSERT INTO votes (user_id, post_id)
--SELECT user_idd, post_id
--FROM user_upvotes_temp
--CASE WHEN user_idd IS NOT NULL THEN vote = 1;
--

--INSERT INTO votes (user_id, user_id, post_id)
--SELECT (LEFT ( user_, STRPOS ( upvotes, ',') -1),
--    (RIGHT ( upvotes, STRPOS ( upvotes, ',') +1),



--INSERT INTO user_votes (username, post_id, vote)
--SELECT udt.username,
--    udt.post_id,
--    -1
--FROM udt;
--
--INSERT INTO user_votes (username, post_id, vote)
--SELECT uut.username,
--    uut.post_id,
--    1
--FROM uut;


--  Testing we get the same value;
--postgres=# SELECT COUNT(DISTINCT user_id) FROM user_votes;
-- count
---------
--  1100
--(1 row)


--UPDATE user_votes SET user_id = (
--    SELECT users.id
--    FROM users
--WHERE users.username = user_votes.username);
--
--ALTER TABLE user_votes DROP COLUMN username;


--DROP TABLE users, user_votes, posts, comments, topics;
