-- Exercises involving Views, Procedures, Functions and Triggers
-- Denise Rezende

-- Consider the instance implemented and populated in SQL in the last activity for the LIBRARY
-- relational database schema in the next page, which is used to keep track of books, borrowers,
-- and book loans. Referential integrity constraints are shown as directed arcs in the figure.

-- Creating tables
-- 3. PUBLISHER
-- name, address, phone
-- DROP TABLE denise.publisher CASCADE CONSTRAINTS;
CREATE TABLE denise.publisher (
  publisher_name VARCHAR(100),
  address VARCHAR(100),
  phone VARCHAR(100),
  CONSTRAINT pk_publisher PRIMARY KEY (publisher_name)
);

-- 1. BOOK
-- book_id, title, publisher_name
-- DROP TABLE denise.book CASCADE CONSTRAINTS;
CREATE TABLE denise.book (
  book_id NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
  title VARCHAR(100),
  publisher_name VARCHAR(100),
  CONSTRAINT pk_book PRIMARY KEY (book_id),
  CONSTRAINT fk_publisher_name FOREIGN KEY (publisher_name)
    REFERENCES denise.publisher (publisher_name)
);


-- 2. BOOK_AUTHORS
-- book_id, author_name
-- DROP TABLE denise.book_authors CASCADE CONSTRAINTS;
CREATE TABLE denise.book_authors(
	book_id INT UNIQUE,
	author_name VARCHAR(100),
	CONSTRAINT pk_book_authors PRIMARY KEY(book_id, author_name),
	CONSTRAINT fk_book_id_ba FOREIGN KEY(book_id)
		REFERENCES denise.book(book_id)
);

-- 6. LIBRARY_BRANCH
-- branch_id, branch_name, address
-- DROP TABLE denise.library_branch CASCADE CONSTRAINTS;
CREATE TABLE denise.library_branch(
	branch_id NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
	branch_name VARCHAR(100),
	address VARCHAR(100),
	CONSTRAINT pk_library_branch PRIMARY KEY(branch_id)
);

-- 4. BOOK_COPIES
-- book_id, branch_id, no_of_copies
CREATE TABLE denise.book_copies(
	book_id INT,
	branch_id INT,
	no_of_copies INTEGER,
	CONSTRAINT pk_book_copies PRIMARY KEY(book_id, branch_id),
	CONSTRAINT fk_book_id_bc FOREIGN KEY(book_id)
		REFERENCES denise.book(book_id),
	CONSTRAINT fk_branch_id_bc FOREIGN KEY(branch_id)
		REFERENCES denise.library_branch(branch_id)
);

-- 7. BORROWER
-- card_no, name, address, phone
CREATE TABLE denise.borrower(
	card_no NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
	person_name VARCHAR(100),
	address VARCHAR(100),
	phone VARCHAR(100),
	CONSTRAINT pk_borrower PRIMARY KEY(card_no)
);

-- 5. BOOK_LOANS
-- book_id, branch_id, card_no, date_out, due_date
CREATE TABLE denise.book_loans(
	book_id INT,
	branch_id INT,
	card_no INT,
	date_out DATE,
	due_date DATE,
	date_in DATE DEFAULT NULL,
	CONSTRAINT pk_book_loans PRIMARY KEY(book_id, branch_id, card_no),
	CONSTRAINT fk_book_id_bl FOREIGN KEY(book_id)
		REFERENCES denise.book(book_id),
	CONSTRAINT fk_branch_id_bl FOREIGN KEY(branch_id)
		REFERENCES denise.library_branch(branch_id),
	CONSTRAINT fk_card_no_bl FOREIGN KEY(card_no)
		REFERENCES denise.borrower(card_no)
);

COMMIT;


-- Creating function and trigger
CREATE OR REPLACE FUNCTION check_book_copies(
    p_book_id IN denise.book_copies.book_id%TYPE,
    p_branch_id IN denise.book_copies.branch_id%TYPE
)
RETURN BOOLEAN
IS
   available_copies INTEGER;
BEGIN
   -- Compute the number of available book copies
    SELECT book_copies_.no_of_copies - COUNT(book_loans_.book_id)
        into available_copies
    FROM denise.book_copies book_copies_
    LEFT JOIN denise.book_loans book_loans_ ON book_copies_.book_id = book_loans_.book_id
                                            AND book_copies_.branch_id = book_loans_.branch_id
                                            AND book_loans_.date_in IS NULL
    WHERE book_copies_.book_id = p_book_id and book_copies_.branch_id = p_branch_id
    GROUP BY book_copies_.no_of_copies;

   -- If there are no available copies, raise an exception
   IF available_copies <= 0 THEN
      RAISE_APPLICATION_ERROR(-20001, 'No available copies for book ' || p_book_id || ' at branch ' || p_branch_id);
   END IF;

   RETURN TRUE;
END;
/


CREATE TRIGGER book_loans_trigger
BEFORE INSERT ON denise.book_loans
FOR EACH ROW
BEGIN
   -- Call the check_book_copies function to validate the loan request
   if not check_book_copies(:new.book_id, :new.branch_id) then
       raise_application_error(-20002, 'Failed to check available copies for book ' || :new.book_id || ' at branch ' || :new.branch_id);
   end if;
END;
/

COMMIT;
