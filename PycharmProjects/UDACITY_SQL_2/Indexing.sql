--Quiz:

--1
CREATE INDEX ON authors ("id");
CREATE INDEX ON books ("id");

--2
CREATE INDEX ON books("author_id", "title");

--3
CREATE INDEX ON books ("isbn");

--4
CREATE INDEX ON books ("title" VARCHAR_PATTERN_OPS);

--5
CREATE INDEX ON book_topics("book_id", "topic_id");

--6
CREATE INDEX ON book_topics("topic_id", "book_id");


-- Solutions:

-- Constraints
ALTER TABLE "authors"
  ADD PRIMARY KEY ("id");

ALTER TABLE "topics"
  ADD PRIMARY KEY("id"),
  ADD UNIQUE ("name"),
  ALTER COLUMN "name" SET NOT NULL;

ALTER TABLE "books"
  ADD PRIMARY KEY ("id"),
  ADD UNIQUE ("isbn"),
  ADD FOREIGN KEY ("author_id") REFERENCES "authors" ("id");

ALTER TABLE "book_topics"
  ADD PRIMARY KEY ("book_id", "topic_id");
-- or ("topic_id", "book_id") instead...?

-- We need to be able to quickly find books and authors by their IDs.
-- Already taken care of by primary keys

-- We need to be able to quickly tell which books an author has written.
CREATE INDEX "find_books_by_author" ON "books" ("author_id");

-- We need to be able to quickly find a book by its ISBN #.
-- The unique constraint on ISBN already takes care of that
--   by adding a unique index

-- We need to be able to quickly search for books by their titles
--   in a case-insensitive way, even if the title is partial. For example,
--   searching for "the" should return "The Lord of the rings".
CREATE INDEX "find_books_by_partial_title" ON "books" (
  LOWER("title") VARCHAR_PATTERN_OPS
);

-- For a given book, we need to be able to quickly find all the topics
--   associated with it.
-- The primary key on the book_topics table already takes care of that
--   since there's an underlying unique index

-- For a given topic, we need to be able to quickly find all the books
--   tagged with it.
CREATE INDEX "find_books_by_topic" ON "book_topics" ("topic_id");


--Creating a complete schema exercise:

--Tables

CREATE TABLE "movies" (
    "id" BIGSERIAL PRIMARY KEY,
    "title" VARCHAR(50),-- Think about why to use VARCHAR over TEXT
    "description" TEXT); -- Remember data on the order of GB can be stored in TEXT
-- Correct

CREATE TABLE "users" (
    "id" BIGSERIAL PRIMARY KEY,
    "name"  VARCHAR(20));
-- Correct

ALTER TABLE users ADD CONSTRAINT unique_users UNIQUE ("name"); --case senstive...
-- Correct mostly, but no need for the constraint here

CREATE TABLE "categories" (
    "id" SERIAL PRIMARY KEY,
    "category" VARCHAR(50) UNIQUE);
-- Correct

CREATE TABLE "movie_categories" (
    "movie_id" BIGINT,
    "category_id" INTEGER,
    FOREIGN KEY (movie_id) REFERENCES movies (id),
    FOREIGN KEY (category_id) REFERENCES categories (id) -- No need to declare the column as Postgres will automatically reference the PK
    );-- PRIMARY KEY ("movie_id", "category_id")

CREATE TABLE "ratings" (
    "user_id" BIGINT,
    "movie_id" BIGINT,
    "rating" SMALLINT,
    FOREIGN KEY (user_id) REFERENCES users (id), -- Again, no need to specify the column
    FOREIGN KEY (movie_id) REFERENCES users (id),
    CHECK (rating >= 0 AND rating <= 100),
    UNIQUE(user_id, movie_id) -- Instead of UNIQUE constrain as PRIMARY KEY
    );
-- Mostly correct

CREATE TABLE "user_preferences" (
    "category_id" INTEGER,
    "user_id" BIGINT,
    "like" BOOL,
    FOREIGN KEY (category_id) REFERENCES categories(id),
    FOREIGN KEY (user_id) REFERENCES users(id)  ON DELETE CASCADE,
    UNIQUE(category_id, user_id)
    );

-- Indices

CREATE INDEX ON movies(title VARCHAR_PATTERN_OPS);

CREATE  INDEX ON users(name);
-- CREATE INDEX ON users LOWER('name');

CREATE INDEX ON user_preferences(user_id, category_id);
CREATE INDEX ON ratings(user_id, movie_id);

CREATE INDEX ON ratings(movie_id, user_id); -- Can be done only referencing movie_id

CREATE INDEX ON user_preferences("category_id", "like", "user_id"); -- Can be done only referencing category_id

--Solution:
CREATE TABLE "movies" (
  "id" SERIAL PRIMARY KEY,
  "title" VARCHAR(500), --  Night of the Day of the Dawn of the Son of the Bride of the Return of the Revenge of the Terror of the Attack of the Evil, Mutant, Hellbound, Flesh-Eating Subhumanoid Zombified Living Dead, Part 3
  "description" TEXT
);


CREATE TABLE "categories" (
  "id" SERIAL PRIMARY KEY,
  "name" VARCHAR(50) UNIQUE
);

CREATE TABLE "movie_categories" (
  "movie_id" INTEGER REFERENCES "movies",
  "category_id" INTEGER REFERENCES "categories",
  PRIMARY KEY ("movie_id", "category_id")
);

CREATE TABLE "users" (
  "id" SERIAL PRIMARY KEY,
  "username" VARCHAR(100),
);
CREATE UNIQUE INDEX ON "users" (LOWER("username"));

CREATE TABLE "user_movie_ratings" (
  "user_id" INTEGER REFERENCES "users",
  "movie_id" INTEGER REFERENCES "movies",
  "rating" SMALLINT CHECK ("rating" BETWEEN 0 AND 100),
  PRIMARY KEY ("user_id", "movie_id")
);
CREATE INDEX ON "user_movie_ratings" ("movie_id");

CREATE TABLE "user_category_likes" (
  "user_id" INTEGER REFERENCES "users",
  "category_id" INTEGER REFERENCES "categories",
  PRIMARY KEY ("user_id", "category_id")
);
CREATE INDEX ON "user_category_likes" ("category_id");

