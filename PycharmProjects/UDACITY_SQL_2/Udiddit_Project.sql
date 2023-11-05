--DDL
CREATE TABLE users (
    "id" BIGSERIAL  PRIMARY KEY,
    "username" VARCHAR(25) UNIQUE NOT NULL,
    "joined" TIMESTAMP WITH TIME ZONE,
    "last_logon" TIMESTAMP WITH TIME ZONE
);


CREATE TABLE topics (
    "id" BIGSERIAL PRIMARY KEY,
    "created_on" TIMESTAMP WITH TIME ZONE,
    "name" VARCHAR(30) UNIQUE NOT NULL,
    "description" TEXT DEFAULT NULL
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
    "post_id" BIGINT,
    "vote" SMALLINT CHECK (vote = 1 OR vote = -1),
    UNIQUE(user_id, post_id),
    FOREIGN KEY (user_id) REFERENCES users ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES posts ON DELETE CASCADE
);

--DML

INSERT INTO users (username) SELECT DISTINCT username FROM bad_comments;

INSERT INTO topics (name) SELECT DISTINCT topic FROM bad_posts;

--SELECT * FROM bad_posts bp JOIN bad_comments bc ON bp.text_content = bc.text_content;
