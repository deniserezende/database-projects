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
CREATE TEMPORARY TABLE table_with_no_copies AS
	SELECT 
		t1.branch_id,
		t2.book_id,
		t2.no_of_copies
	FROM
	(
	SELECT
		_book_copies.branch_id
	FROM 
        "LIBRARY".BOOK_COPIES _book_copies
    GROUP BY
        _book_copies.branch_id
	) AS t1
	
	JOIN
	
	(
	SELECT
		_book_copies.branch_id,
		_book_copies.book_id,
		_book_copies.no_of_copies
		
	FROM 
        "LIBRARY".BOOK_COPIES _book_copies
	) AS t2
	
	ON t1.branch_id = t2.branch_id
	
	ORDER BY t1.branch_id;
	
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

-- DROP TABLE "LIBRARY".BOOK_COPIES_INDIVIDUAL CASCADE;
-- Create new table (id, acquisition date, current conditions)
CREATE TABLE "LIBRARY".BOOK_COPIES_INDIVIDUAL (
	individual_id SERIAL NOT NULL,
	book_id INT,
	branch_id INT,
	acquisition_date DATE NOT NULL,
  	book_condition VARCHAR(10) CHECK (book_condition IN ('fine', 'good', 'fair', 'poor')) NOT NULL,
	
	CONSTRAINT pk_book_copies_individual PRIMARY KEY(individual_id),
	CONSTRAINT fk_book_id_bci FOREIGN KEY(book_id)
		REFERENCES "LIBRARY".BOOK(book_id),
	CONSTRAINT fk_branch_id_bci FOREIGN KEY(branch_id)
		REFERENCES "LIBRARY".LIBRARY_BRANCH(branch_id)
);

-- Book loans should refer to a specific book copy. 
-- Should reference the individual_id
-- Creating column
-- ALTER TABLE "LIBRARY".BOOK_LOANS DROP COLUMN individual_id
ALTER TABLE "LIBRARY".BOOK_LOANS
ADD COLUMN individual_id INT,
ADD CONSTRAINT fk_individual_id
FOREIGN KEY (individual_id) REFERENCES "LIBRARY".BOOK_COPIES_INDIVIDUAL (individual_id);

ALTER TABLE "LIBRARY".BOOK_LOANS
ADD CONSTRAINT unique_individual_id_bl UNIQUE (individual_id);

-- Insert values in table
--  Cartesian product of each book copy in the book_copies table 
-- and a series of numbers from 1 to the number of copies for each book.
-- DROP FUNCTION insert_values_in_book_individual_id()
-- Book loans should refer to a specific book copy. 
-- Should reference the individual_id
CREATE OR REPLACE FUNCTION insert_values_in_book_individual_id() RETURNS VOID AS $$
DECLARE
    ncopies INTEGER;
	loop_i INTEGER;
	temp_id INTEGER;
	book record;
	book_loaned record;
BEGIN
	FOR book IN (SELECT * FROM "LIBRARY".book_copies) LOOP
		ncopies := book.no_of_copies;		
		loop_i := 0;
		WHILE loop_i < ncopies LOOP
			-- Inserting value in new table
			INSERT INTO "LIBRARY".BOOK_COPIES_INDIVIDUAL(book_id, branch_id, acquisition_date, book_condition)
			VALUES (book.book_id, book.branch_id, '01/01/2018', 'fine') 
			RETURNING individual_id INTO temp_id;
			RAISE NOTICE 'temp_id: %', temp_id;
			
			-- Inserting individual id in book loans
			SELECT * INTO book_loaned FROM "LIBRARY".BOOK_LOANS WHERE book.book_id = book_id AND book.branch_id = branch_id 
				AND individual_id IS NULL LIMIT 1;
			UPDATE "LIBRARY".BOOK_LOANS 
			SET individual_id = temp_id
			WHERE book_loaned.card_no = card_no
			AND book.book_id = book_id
			AND book.branch_id = branch_id;
			
			loop_i := loop_i + 1;
		END LOOP;
	END LOOP;
END;
$$ LANGUAGE plpgsql;

SELECT insert_values_in_book_individual_id();

-- Adding not null to both tables
ALTER TABLE "LIBRARY".BOOK_LOANS
ALTER COLUMN individual_id SET NOT NULL;

ALTER TABLE "LIBRARY".BOOK_COPIES_INDIVIDUAL
ADD CONSTRAINT unique_individual_id_bci UNIQUE (individual_id);

-- See tables
SELECT * FROM "LIBRARY".BOOK_COPIES_INDIVIDUAL;
SELECT * FROM "LIBRARY".BOOK_COPIES;
SELECT * FROM "LIBRARY".BOOK_LOANS ORDER BY individual_id;

-- Book loans should refer to a specific book copy. 
-- Should reference the individual_id
-- Por isso é obrigatório que o individual_id seja informado ao fazer um loan

-- Teste inserindo um novo loan
-- Assim não funciona pois individual_id não pode ser nulo
-- INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
-- VALUES (3, 2, 3, '2022-01-21', '2022-03-03');

-- Assim não funciona pois o livro não está disponível
-- INSERT INTO "LIBRARY".BOOK_LOANS(individual_id, book_id, branch_id, card_no, date_out, due_date)
-- VALUES (11, 3, 2, 3, '2022-01-21', '2022-03-03');

-- Esse funciona ou seja está certo
INSERT INTO "LIBRARY".BOOK_LOANS(individual_id, book_id, branch_id, card_no, date_out, due_date)
VALUES (19, 5, 2, 3, '2022-01-21', '2022-03-03');


-- The attribute no_of_copies should no longer be stored in the
-- database. However, existing applications should "see" the database as if the schema had not been
-- updated for backward compatibility.
-- DROP VIEW "LIBRARY".BOOKS_WITH_COPIES
CREATE VIEW "LIBRARY".BOOKS_WITH_COPIES AS
SELECT book_id, branch_id, 
	(SELECT COUNT(*) FROM "LIBRARY".BOOK_COPIES WHERE book_id = _book_copies.book_id) AS no_of_copies
FROM "LIBRARY".BOOK_COPIES _book_copies;

ALTER TABLE "LIBRARY".BOOK_COPIES
DROP COLUMN no_of_copies;

SELECT * FROM "LIBRARY".BOOKS_WITH_COPIES;
SELECT * FROM "LIBRARY".BOOK_COPIES;

-- There are no inconsistencies in the BOOK_COPIES_INDIVIDUALS
DROP TABLE table_with_no_copies; 
DROP TABLE "LIBRARY".BOOK_COPIES CASCADE; 


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
CREATE VIEW "LIBRARY".BOOK_COPIES AS
SELECT _book.book_id, _book_copies_individual.branch_id, COUNT(*) AS no_of_copies
FROM "LIBRARY".book _book
JOIN "LIBRARY".book_copies_individual _book_copies_individual ON _book.book_id = _book_copies_individual.book_id
GROUP BY _book_copies_individual.branch_id, _book.book_id;

SELECT * FROM "LIBRARY".BOOK_COPIES;


-- Creating trigger to delete items in the view and function
CREATE OR REPLACE FUNCTION delete_book_in_book_copies()
    RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM "LIBRARY".book_copies_individual 
	WHERE book_id = OLD.book_id AND branch_id = OLD.branch_id;
    RETURN new;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER delete_book_in_book_copies
    INSTEAD OF DELETE ON "LIBRARY".book_copies
    FOR EACH ROW EXECUTE FUNCTION delete_book_in_book_copies();
	


-- Creating trigger to insert items in the view and function
CREATE OR REPLACE FUNCTION "LIBRARY".insert_book_in_book_copies() RETURNS TRIGGER AS $$
DECLARE
    _index INTEGER := 1;
BEGIN
    WHILE _index <= NEW.no_of_copies LOOP
        INSERT INTO "LIBRARY".book_copies_individual(book_id, branch_id, acquisition_date, book_condition)
        VALUES(NEW.book_id, NEW.branch_id, CURRENT_DATE, 'poor');
        _index := _index + 1;
    END LOOP;
    RETURN NEW;
END;
$$ LANGUAGE PLPGSQL;

CREATE TRIGGER insert_book_in_book_copies
    INSTEAD OF INSERT ON "LIBRARY".book_copies
    FOR EACH ROW EXECUTE FUNCTION "LIBRARY".insert_book_in_book_copies();


-- TEST EXERCISE TWO:
-- Deleting
DELETE FROM "LIBRARY".book_copies bc WHERE bc.book_id = 1;
SELECT * FROM "LIBRARY".book_copies;
SELECT * FROM "LIBRARY".book_copies_individual;

-- Updating value of no_of_copies
SELECT * FROM "LIBRARY".book;
INSERT INTO "LIBRARY".book_copies(book_id, branch_id, no_of_copies)
VALUES(8, 1, 20);
SELECT * FROM "LIBRARY".book_copies;
SELECT * FROM "LIBRARY".book_copies_individual;

-- Inserting
INSERT INTO "LIBRARY".book(title, publisher_name)
VALUES('Poder Oculto da Amabilidade', 'Editorial Sudamericana');
INSERT INTO "LIBRARY".book_copies(book_id, branch_id, no_of_copies)
VALUES(12, 1, 20);
SELECT * FROM "LIBRARY".book_copies;
SELECT * FROM "LIBRARY".book_copies_individual;


-- • Show the database state before and after executing inserts, updates and deletes on the view,
-- showing that the triggered actions satisfy all the specifications' points.
-- PDF





