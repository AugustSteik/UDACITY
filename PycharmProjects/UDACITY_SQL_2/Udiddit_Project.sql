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
    "description" VARCHAR(500) DEFAULT NULL,
    FOREIGN KEY (user_id) REFERENCES users
);

CREATE TABLE posts (
    "id" BIGSERIAL  PRIMARY KEY,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "user_id" BIGINT,
    "topic_id" BIGINT NOT NULL,
    "title" VARCHAR(100) NOT NULL,
    "text_content" TEXT DEFAULT NULL,
    "url" TEXT DEFAULT NULL,
    CHECK ((text_content IS NULL AND url IS NOT NULL) OR (text_content IS NOT NULL AND url IS NULL)),
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (topic_id) REFERENCES topics ON DELETE CASCADE
);

CREATE TABLE comments (
    "id" BIGSERIAL PRIMARY KEY,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "post_id" BIGINT NOT NULL,
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
    "post_id" BIGINT NOT NULL,
    "vote" SMALLINT CHECK (vote = 1 OR vote = -1),
    UNIQUE (user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (post_id) REFERENCES posts ON DELETE CASCADE
);

CREATE INDEX posts_users ON posts(user_id);

CREATE INDEX posts_topics ON posts(topic_id);

CREATE INDEX posts_links ON posts(url);

CREATE INDEX comments_parents ON comments(parent_id);

CREATE INDEX comments_users ON comments(user_id);



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
    SELECT regexp_split_to_table(downvotes, ',') AS username -- Collecting all of the unique usernames present in the database
    FROM bad_posts
) bp2
;

INSERT INTO topics (name) SELECT DISTINCT topic FROM bad_posts;


INSERT INTO posts (id, topic_id, user_id, title, text_content, url)
SELECT bp.id, -- Keeping the existing post IDs
    topics.id,
    users.id,
    SUBSTRING(bp.title, 1, 100) AS  title, --  Trimming the titles down as some are over  100 chars
    bp.text_content,
    bp.url
FROM bad_posts bp
JOIN users ON users.username = bp.username
JOIN topics ON topics.name = bp.topic;


INSERT INTO comments (id, user_id, post_id, content)
SELECT bc.id, -- Keeping the existing comment IDs
    users.id,
    bc.post_id,
    bc.text_content
FROM bad_comments bc
JOIN users ON users.username = bc.username;


CREATE OR REPLACE VIEW udt --User Down-votes Temp
AS (
    SELECT bad_posts.id AS post_id,
    regexp_split_to_table(bad_posts.downvotes, ',') AS username

    FROM bad_posts
);

CREATE OR REPLACE VIEW uut -- User Up-votes Temp
AS (
    SELECT bad_posts.id AS post_id,
    regexp_split_to_table(bad_posts.upvotes, ',') AS username

    FROM bad_posts
);


INSERT INTO user_votes (user_id, post_id, vote)
SELECT users.id,
    udt.post_id,
    -1
FROM udt
JOIN users ON  users.username = udt.username;

INSERT INTO user_votes (user_id, post_id, vote)
SELECT users.id,
    uut.post_id,
    1
FROM uut
JOIN users ON users.username = uut.username;

DROP TABLE bad_posts, bad_comments CASCADE; -- Drops the two tables and their related VIEWs


-- Testing the schema works as expected
SELECT u.username,
    uv.vote,
    t.name AS topic,
    p.title, p.text_content, p.url
FROM  user_votes uv
JOIN users u ON u.id = uv.user_id
JOIN posts p ON p.id = uv.post_id
JOIN topics t ON t.id = p.topic_id;
