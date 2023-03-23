-- Exercises involving Views, Procedures, Functions and Triggers
-- Denise Rezende

-- Consider the instance implemented and populated in SQL in the last activity for the LIBRARY 
-- relational database schema in the next page, which is used to keep track of books, borrowers, 
-- and book loans. Referential integrity constraints are shown as directed arcs in the figure.


-- DROP SCHEMA "LIBRARY" CASCADE;
-- Creating schema
CREATE SCHEMA IF NOT EXISTS "LIBRARY"
    AUTHORIZATION denise;

-- Creating tables
-- 3. PUBLISHER
-- name, address, phone
CREATE TABLE "LIBRARY".PUBLISHER(
	publisher_name VARCHAR(100),
	address VARCHAR(100),
	phone VARCHAR(100),
	CONSTRAINT pk_publisher PRIMARY KEY(publisher_name) 
);

-- 1. BOOK
-- book_id, title, publisher_name
CREATE TABLE "LIBRARY".BOOK(
	book_id SERIAL NOT NULL,
	title VARCHAR(100),
	publisher_name VARCHAR(100),
	CONSTRAINT pk_book PRIMARY KEY(book_id),
	CONSTRAINT fk_publisher_name FOREIGN KEY(publisher_name)
		REFERENCES "LIBRARY".PUBLISHER(publisher_name)
);

-- 2. BOOK_AUTHORS
-- book_id, author_name
CREATE TABLE "LIBRARY".BOOK_AUTHORS(
	book_id INT,
	author_name VARCHAR(100),
	CONSTRAINT pk_book_authors PRIMARY KEY(book_id, author_name),
	CONSTRAINT fk_book_id_ba FOREIGN KEY(book_id)
		REFERENCES "LIBRARY".BOOK(book_id)
);

-- 6. LIBRARY_BRANCH
-- branch_id, branch_name, address
CREATE TABLE "LIBRARY".LIBRARY_BRANCH(
	branch_id SERIAL NOT NULL,
	branch_name VARCHAR(100),
	address VARCHAR(100),
	CONSTRAINT pk_library_branch PRIMARY KEY(branch_id)
);

-- 4. BOOK_COPIES
-- book_id, branch_id, no_of_copies
CREATE TABLE "LIBRARY".BOOK_COPIES(
	book_id INT,
	branch_id INT,
	no_of_copies INTEGER,
	CONSTRAINT pk_book_copies PRIMARY KEY(book_id, branch_id),
	CONSTRAINT fk_book_id_bc FOREIGN KEY(book_id)
		REFERENCES "LIBRARY".BOOK(book_id),
	CONSTRAINT fk_branch_id_bc FOREIGN KEY(branch_id)
		REFERENCES "LIBRARY".LIBRARY_BRANCH(branch_id)
);

-- 7. BORROWER
-- card_no, name, address, phone
CREATE TABLE "LIBRARY".BORROWER(
	card_no SERIAL NOT NULL,
	person_name VARCHAR(100),
	address VARCHAR(100),
	phone VARCHAR(100),
	CONSTRAINT pk_borrower PRIMARY KEY(card_no)
);

-- 5. BOOK_LOANS
-- book_id, branch_id, card_no, date_out, due_date
CREATE TABLE "LIBRARY".BOOK_LOANS(
	book_id INT,
	branch_id INT,
	card_no SERIAL,
	date_out DATE, 
	due_date DATE,
	date_in DATE DEFAULT NULL,
	CONSTRAINT pk_book_loans PRIMARY KEY(book_id, branch_id, card_no),
	CONSTRAINT fk_book_id_bl FOREIGN KEY(book_id)
		REFERENCES "LIBRARY".BOOK(book_id),
	CONSTRAINT fk_branch_id_bl FOREIGN KEY(branch_id)
		REFERENCES "LIBRARY".LIBRARY_BRANCH(branch_id),
	CONSTRAINT fk_card_no_bl FOREIGN KEY(card_no)
		REFERENCES "LIBRARY".BORROWER(card_no)
);

-- TRIGGER to assure that a book is only loaned if there is an available copy
-- Creating function that will be called in the trigger
CREATE OR REPLACE FUNCTION check_book_copies() RETURNS TRIGGER AS $$
DECLARE
    available_copies INTEGER;
BEGIN
    SELECT no_of_copies - COUNT(_book_loans.book_id)
	INTO available_copies
	-- Using a left join ensures that all book copies are included in the count, 
	-- even if there is no corresponding loan record.
    FROM "LIBRARY".BOOK_COPIES _book_copies LEFT JOIN "LIBRARY".BOOK_LOANS _book_loans
    ON _book_copies.book_id = _book_loans.book_id AND _book_copies.branch_id = _book_loans.branch_id
    WHERE _book_copies.book_id = NEW.book_id AND _book_copies.branch_id = NEW.branch_id
	-- This insures the book hasn't been returned
	-- only currently borrowed book copies are considered for the count.
    AND _book_loans.date_in IS NULL
	GROUP BY _book_copies.book_id, _book_copies.branch_id;
	
	-- Debug 
	RAISE NOTICE '% available copies for book_id % and branch_id %', available_copies, NEW.book_id, NEW.branch_id;
    
	IF available_copies < 1 THEN
        RAISE EXCEPTION 'No available copies for book_id % and branch_id %.', NEW.book_id, NEW.branch_id;
    END IF;
	IF available_copies is NULL THEN 
		RAISE EXCEPTION 'The book with book_id % and branch_id % doesn''t exist.', NEW.book_id, NEW.branch_id;
	END IF;
	
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Creating trigger
CREATE TRIGGER book_loans_trigger 
	BEFORE INSERT ON "LIBRARY".BOOK_LOANS
	FOR EACH ROW EXECUTE FUNCTION check_book_copies();

-- -- TRIGGER that sets date in after a book is restored 



