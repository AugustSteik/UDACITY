--DDL
CREATE TABLE users (
    "id" BIGSERIAL  PRIMARY KEY,
    "username" VARCHAR(25) UNIQUE NOT NULL,
    "joined" TIMESTAMP WITH TIME ZONE,
    "last_logon" TIMESTAMP WITH TIME ZONE
);


CREATE TABLE topics (
    "id" BIGSERIAL PRIMARY KEY,
    "user_id" BIGINT,
    "name" VARCHAR(30) UNIQUE NOT NULL,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "description" TEXT DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users--???
);


CREATE TABLE posts (
    "id" BIGSERIAL  PRIMARY KEY,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "user_id" BIGINT,
    "topic_id" BIGINT,
    "title" VARCHAR(100) NOT NULL,
    "text_content"  TEXT DEFAULT NULL,
    "url" TEXT DEFAULT NULL,
    CHECK ((text_content IS NULL AND url IS NOT NULL) OR (text_content IS NOT NULL AND url IS NULL)),
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (topic_id) REFERENCES topics ON DELETE CASCADE
);

CREATE TABLE comments (
    "id" BIGSERIAL PRIMARY KEY,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "post_id" BIGINT,
    "user_id" BIGINT,
    "parent_id" BIGINT,
    "content" TEXT NOT NULL,
    FOREIGN KEY (post_id) REFERENCES posts ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (parent_id) REFERENCES comments ON DELETE CASCADE
);

CREATE TABLE user_votes (
    "id" BIGSERIAL PRIMARY KEY,
    "voted_on" TIMESTAMP WITH TIME ZONE,
    "user_id" BIGINT,
    "username" VARCHAR(25),
    "post_id" BIGINT,
    "vote" SMALLINT CHECK (vote = 1 OR vote = -1),
    UNIQUE(user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (post_id) REFERENCES posts ON DELETE CASCADE
);

--DML

INSERT INTO users (username)
SELECT DISTINCT username FROM bad_comments
UNION
SELECT DISTINCT username FROM bad_posts
UNION
SELECT DISTINCT username FROM (
    SELECT regexp_split_to_table(upvotes, ',') AS username
    FROM bad_posts
) bp1
UNION
SELECT DISTINCT username FROM (
    SELECT regexp_split_to_table(downvotes, ',') AS username
    FROM bad_posts
) bp2
;

INSERT INTO topics (name) SELECT DISTINCT topic FROM bad_posts;

INSERT INTO posts (id, topic_id, user_id, title, text_content, url)
SELECT bp.id,
    topics.id,
    users.id,
    bp.title,
    bp.text_content,
    bp.url
FROM bad_posts bp
JOIN users ON users.username = bad_posts.username
JOIN topics ON topics.name = bad_posts.topic;

-- NEED CHECKING /\  \/

INSERT INTO comments (id, user_id, post_id, content)
SELECT bc.id,
    users.id,
    bc.post_id,
    bc.text_content
FROM bad_comments bc
JOIN users ON users.username = bc.username;


-- navigating existing schema:
SELECT COUNT(title) FROM bad_posts; = 50000
SELECT DISTINCT COUNT(title) FROM bad_posts; = 50000

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

-------------------------------------------------------------------------------------------
--v2
CREATE OR REPLACE VIEW udt
AS (
    SELECT bad_posts.id AS post_id,
    regexp_split_to_table(bad_posts.downvotes, ',') AS username

    FROM bad_posts
);

CREATE OR REPLACE VIEW uut
AS (
    SELECT bad_posts.id AS post_id,
    regexp_split_to_table(bad_posts.upvotes, ',') AS username

    FROM bad_posts
);



INSERT INTO user_votes (username, post_id, vote)
SELECT udt.username,
    udt.post_id,
    -1
FROM udt;

INSERT INTO user_votes (username, post_id, vote)
SELECT uut.username,
    uut.post_id,
    1
FROM uut;


UPDATE user_votes SET user_id = (
    SELECT users.id
    FROM users
WHERE users.username = user_votes.username);


