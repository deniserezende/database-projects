-- 2. Assume that after having deployed the database and loaded it with data, the library manager
-- decided to store book copies individually.
-- From now on, the database should store an id, the
-- acquisition date, and the current conditions (fine, good, fair, or poor) for each copy.
-- Book loans should refer to a specific book copy. The attribute no_of_copies should no longer be stored in the
-- database. However, existing applications should "see" the database as if the schema had not been
-- updated for backward compatibility.
-- • Create a temporary table to save the current number of copies of each book in each branch.
-- • Implement the commands to perform the necessary change to the database schema.
-- • Write a query or a function that returns/shows the inconsistencies between the number of
-- copies of a book in a branch in the updated schema and the respective number of copies in
-- the temporary table. That is, identify the cases these numbers do not match.
-- • Insert book copies into the updated schema until there is no more such an inconsistency.
-- Commit the changes and drop the temporary table.
-- • Create a view with the same name as the old table (book_copies), showing the same content.
-- That is, an application could interact with the view as it was the old table.
-- ◦ A delete from the view should trigger the deletion of the tuples corresponding to the
-- book copies.
-- ◦ An update on the view to attributes book_id or branch_id should be automatically
-- redirected to the base tables.
-- ◦ An update on the view reducing the number of copies cannot be accepted.
-- ◦ An insert into the view or an update on the view increasing the number of copies should
-- trigger the insertion of book copy tuples such that the number of copies matches the
-- value provided to the update statement. The new tuples' id should be set using a
-- sequence, and their acquisition date should be the current date.
-- • Show the database state before and after executing inserts, updates and deletes on the view,
-- showing that the triggered actions satisfy all the specifications' points.


-- DROP TABLE table_with_no_copies;
-- • Create a temporary table to save the current number of copies of each book in each branch.
CREATE GLOBAL TEMPORARY TABLE table_with_no_copies
ON COMMIT PRESERVE ROWS
	AS SELECT
		book_copies_.branch_id,
		book_copies_.book_id,
		book_copies_.no_of_copies
	FROM
        denise.book_copies book_copies_
	ORDER BY book_copies_.branch_id, book_copies_.book_id;

SELECT * FROM table_with_no_copies;

-- • Implement the commands to perform the necessary change to the database schema.
-- 2. Assume that after having deployed the database and loaded it with data, the library manager
-- decided to store book copies individually.
-- From now on, the database should store an id, the
-- acquisition date, and the current conditions (fine, good, fair, or poor) for each copy.
-- Book loans should refer to a specific book copy.
-- The attribute no_of_copies should no longer be stored in the
-- database. However, existing applications should "see" the database as if the schema had not been
-- updated for backward compatibility.
-- mudar a tabela book_copies para eles serem guardados individualmente
--Create a new table called book_copies_individual to store individual book copies:
-- • Insert book copies into the updated schema until there is no more such an inconsistency.
-- Commit the changes and drop the temporary table.

-- DROP TABLE denise.book_copies_individual CASCADE;
-- Create new table (id, acquisition date, current conditions)
CREATE TABLE denise.book_copies_individual (
	individual_id NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
	book_id INT,
	branch_id INT,
	acquisition_date DATE NOT NULL,
  	book_condition VARCHAR(10) CHECK (book_condition IN ('fine', 'good', 'fair', 'poor')) NOT NULL,

	CONSTRAINT pk_book_copies_individual PRIMARY KEY(individual_id),
	CONSTRAINT fk_book_id_bci FOREIGN KEY(book_id)
		REFERENCES denise.book(book_id),
	CONSTRAINT fk_branch_id_bci FOREIGN KEY(branch_id)
		REFERENCES denise.library_branch(branch_id)
);

-- Book loans should refer to a specific book copy.
-- Should reference the individual_id
-- Creating column
-- ALTER TABLE "LIBRARY".BOOK_LOANS DROP COLUMN individual_id
ALTER TABLE denise.book_loans
ADD individual_id NUMBER;
ALTER TABLE denise.book_loans
ADD CONSTRAINT fk_individual_id
FOREIGN KEY (individual_id) REFERENCES denise.book_copies_individual (individual_id);
ALTER TABLE denise.book_loans
ADD CONSTRAINT unique_individual_id_bl UNIQUE (individual_id);

-- Insert values in table
--  Cartesian product of each book copy in the book_copies table
-- and a series of numbers from 1 to the number of copies for each book.
-- DROP FUNCTION insert_values_in_book_individual_id()
-- Book loans should refer to a specific book copy.
-- Should reference the individual_id
-- SET SERVEROUTPUT ON;
CREATE OR REPLACE PROCEDURE insert_values_in_book_individual_id
AS
    ncopies INTEGER;
    loop_i INTEGER;
    temp_id INTEGER;
    book book_copies%ROWTYPE;
    book_loaned book_loans%ROWTYPE;
BEGIN
    FOR book IN (SELECT BOOK_ID, BRANCH_ID, NO_OF_COPIES  FROM denise.book_copies) LOOP
        ncopies := book.no_of_copies;
        loop_i := 0;
        DBMS_OUTPUT.PUT_LINE('book =' || book.book_id || ' no_of_copies=' || book.no_of_copies);
        FOR i IN 1..ncopies LOOP
            -- Inserting value in new table
            INSERT INTO denise.book_copies_individual(book_id, branch_id, acquisition_date, book_condition)
            VALUES (book.book_id, book.branch_id, TO_DATE('2018-01-01', 'YYYY-MM-DD'), 'fine')
            RETURNING individual_id INTO temp_id;

            DBMS_OUTPUT.PUT_LINE('Inserted individual_id=' || temp_id || ' for book_id=' || book.book_id || ' and branch_id=' || book.branch_id);

            -- Inserting individual id in book loans
            BEGIN
                SELECT book_loan.*
                INTO book_loaned
                FROM denise.book_loans book_loan
                WHERE book_loan.book_id = book.book_id
                  AND book_loan.branch_id = book.branch_id
                  AND book_loan.individual_id IS NULL
                  AND ROWNUM = 1;

                -- Update individual id in book loans
                UPDATE denise.book_loans
                SET individual_id = temp_id
                WHERE card_no = book_loaned.card_no
                  AND book_id = book.book_id
                  AND branch_id = book.branch_id;
                DBMS_OUTPUT.PUT_LINE('Updated book_loans');
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    DBMS_OUTPUT.PUT_LINE('No data found in book_loans for book_id=' || book.book_id || ' and branch_id=' || book.branch_id);
                    -- handle the exception appropriately
            END;
        END LOOP;
    END LOOP;
END;
/

CALL insert_values_in_book_individual_id();
SELECT * FROM denise.book_copies;
SELECT * FROM denise.book_copies_individual;
SELECT * FROM denise.book_loans;

-- Adding not null to table
ALTER TABLE denise.book_loans
MODIFY individual_id NOT NULL;

-- See tables
SELECT * FROM denise.book_copies_individual;
SELECT * FROM denise.book_copies;
SELECT * FROM denise.book_loans ORDER BY individual_id;

-- Book loans should refer to a specific book copy.
-- Should reference the individual_id
-- Por isso é obrigatório que o individual_id seja informado ao fazer um loan


-- Teste inserindo um novo loan
-- Assim não funciona, pois individual_id não pode ser nulo
-- INSERT INTO denise.BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
-- VALUES (3, 2, 3, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-03-03', 'YYYY-MM-DD'));

-- Assim não funciona, pois o livro não está disponível
-- INSERT INTO denise.BOOK_LOANS(individual_id, book_id, branch_id, card_no, date_out, due_date)
-- VALUES (11, 3, 2, 3, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-03-03', 'YYYY-MM-DD'));

-- Esse funciona, ou seja, está certo
INSERT INTO denise.BOOK_LOANS(individual_id, book_id, branch_id, card_no, date_out, due_date)
VALUES (19, 5, 2, 3, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-03-03', 'YYYY-MM-DD'));

SELECT * FROM denise.book_loans ORDER BY individual_id;


-- The attribute no_of_copies should no longer be stored in the
-- database. However, existing applications should "see" the database as if the schema had not been
-- updated for backward compatibility.
-- DROP VIEW denise.BOOKS_WITH_COPIES
CREATE VIEW denise.books_with_copies AS
SELECT book_id, branch_id,
	(SELECT COUNT(*) FROM denise.book_copies_individual
	                 WHERE book_id = book_copies_.book_id
	                 AND branch_id = book_copies_.branch_id) AS no_of_copies
FROM denise.book_copies book_copies_;

ALTER TABLE denise.book_copies
DROP COLUMN no_of_copies;

SELECT * FROM denise.books_with_copies;
SELECT * FROM denise.book_copies;

-- There are no inconsistencies in the BOOK_COPIES_INDIVIDUALS
DROP TABLE table_with_no_copies;
DROP TABLE denise.book_copies CASCADE CONSTRAINTS;


-- • Create a view with the same name as the old table (book_copies), showing the same content.
-- That is, an application could interact with the view as it was the old table.
-- ◦ A delete from the view should trigger the deletion of the tuples corresponding to the
-- book copies.
-- ◦ An update on the view to attributes book_id or branch_id should be automatically
-- redirected to the base tables.
-- ◦ An update on the view reducing the number of copies cannot be accepted.
-- ◦ An insert into the view or an update on the view increasing the number of copies should
-- trigger the insertion of book copy tuples such that the number of copies matches the
-- value provided to the update statement. The new tuples' id should be set using a
-- sequence, and their acquisition date should be the current date.

-- Creating view with the same name as the table dropped
CREATE VIEW denise.book_copies AS
SELECT book_.book_id, book_copies_individual_.branch_id, COUNT(*) AS no_of_copies
FROM denise.book book_
JOIN denise.book_copies_individual book_copies_individual_ ON book_.book_id = book_copies_individual_.book_id
GROUP BY book_copies_individual_.branch_id, book_.book_id;

SELECT * FROM denise.book_copies;


-- Creating trigger to delete items in the view and function
CREATE OR REPLACE TRIGGER delete_book_in_book_copies
INSTEAD OF DELETE ON denise.book_copies
FOR EACH ROW
BEGIN
    DELETE FROM denise.book_copies_individual
    WHERE book_id = :OLD.book_id AND branch_id = :OLD.branch_id;
END;
/



-- Creating trigger to insert items in the view and function
-- Creating trigger to insert items in the view and function
CREATE OR REPLACE TRIGGER insert_book_in_book_copies
INSTEAD OF INSERT ON denise.book_copies
FOR EACH ROW
DECLARE
    index_ INTEGER := 1;
BEGIN
    WHILE index_ <= :NEW.no_of_copies LOOP
        INSERT INTO denise.book_copies_individual(book_id, branch_id, acquisition_date, book_condition)
        VALUES(:NEW.book_id, :NEW.branch_id, SYSDATE, 'poor');
        index_ := index_ + 1;
    END LOOP;
END;
/

-- TEST EXERCISE TWO:
-- Deleting
DELETE FROM denise.book_copies bc WHERE bc.book_id = 1;
SELECT * FROM denise.book_copies;
SELECT * FROM denise.book_copies_individual;

-- Updating value of no_of_copies
SELECT * FROM denise.book;
INSERT INTO denise.book_copies(book_id, branch_id, no_of_copies)
VALUES(8, 1, 20);
SELECT * FROM denise.book_copies;
SELECT * FROM denise.book_copies_individual;

-- Inserting
SELECT * FROM denise.book;
INSERT INTO denise.book(title, publisher_name)
VALUES('Poder Oculto da Amabilidade', 'Editorial Sudamericana');
INSERT INTO denise.book_copies(book_id, branch_id, no_of_copies)
VALUES(11, 1, 20);
SELECT * FROM denise.book_copies;
SELECT * FROM denise.book_copies_individual;


-- • Show the database state before and after executing inserts, updates and deletes on the view,
-- showing that the triggered actions satisfy all the specifications' points.
-- PDF





