-- 1. Create a materialized view month_borrowers that shows the data (card_no, name, address, and phone) 
-- from the borrowers who had (or have) more than one loan whose length (i.e., the difference between the 
-- date out and the due date) is greater than or equal to 30 days. The view should also show the loan length, 
-- the book title and the branch name of these loans. 
-- Besides, perform updates to the base tables, eventually run statements to make the DBMS update the view, 
-- and show the state of the up-to-date materialized view.


-- DROP MATERIALIZED VIEW "LIBRARY".MONTH_BORROWERS; 
DROP MATERIALIZED VIEW IF EXISTS "LIBRARY".MONTH_BORROWERS;

CREATE MATERIALIZED VIEW "LIBRARY".MONTH_BORROWERS AS
SELECT 
	t1.card_no, 
    t1.person_name, 
    t1.address, 
    t1.phone,
    t1.num_loans,
    t2.book_id,
    t2.branch_id,
    t2.date_out,
    t2.due_date,
    t3.title,
    t4.branch_name
FROM 
    (
    SELECT
        _borrower.card_no, 
        _borrower.person_name, 
        _borrower.address, 
        _borrower.phone,
        COUNT(*) as num_loans

    FROM 
        "LIBRARY".BORROWER _borrower
        JOIN "LIBRARY".book_loans _book_loans ON _book_loans.card_no = _borrower.card_no

    -- Only include rows where the loan length is greater than or equal to 30 days
    WHERE 
        _book_loans.due_date - _book_loans.date_out >= 30

    -- Group the results by borrower and book information columns
    GROUP BY
        _borrower.card_no, _borrower.person_name, _borrower.address, _borrower.phone

    -- Only include groups where the borrower has had more than one loan with a loan length greater than or equal to 30 days
    HAVING 
        COUNT(*) > 1

    ORDER BY
        _borrower.card_no
	
    ) AS t1
		
JOIN 

    (
    SELECT
        -- Select book loan information columns from "BOOK_LOANS" table
        _book_loans.book_id,
        _book_loans.branch_id,
        _book_loans.date_out,
        _book_loans.due_date,
        _book_loans.card_no

    FROM 
        "LIBRARY".BOOK_LOANS _book_loans

    -- Only include rows where the loan length is greater than or equal to 30 days
    WHERE 
        _book_loans.due_date - _book_loans.date_out >= 30
    ) AS t2
		
ON t1.card_no = t2.card_no
	
JOIN 
    (
    SELECT
        _book.book_id,
        _book.title

    FROM 
        "LIBRARY".BOOK _book
    ) AS t3
		
ON t3.book_id = t2.book_id

JOIN (
    SELECT
        _library_branch.branch_id,
        _library_branch.branch_name

    FROM 
        "LIBRARY".LIBRARY_BRANCH _library_branch
    ) AS t4
		
ON t4.branch_id = t2.branch_id

ORDER BY
        t1.card_no;

SELECT * FROM "LIBRARY".MONTH_BORROWERS;


-- TRIGGER to update view when updates are made to the base tables
-- plus show the state of the up-to-date materialized view.
-- Creating function that will be called in the trigger
CREATE OR REPLACE FUNCTION update_month_borrowers() RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW "LIBRARY".MONTH_BORROWERS;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- Creating trigger
CREATE TRIGGER borrower_base_table_changed 
	AFTER INSERT OR DELETE OR UPDATE OF card_no ON "LIBRARY".BORROWER
	FOR EACH ROW EXECUTE FUNCTION update_month_borrowers();

CREATE TRIGGER book_loans_base_table_changed 
	AFTER INSERT OR DELETE OR UPDATE OF card_no ON "LIBRARY".BOOK_LOANS
	FOR EACH ROW EXECUTE FUNCTION update_month_borrowers();


-- DATA TO TEST EXERCISE ONE:
INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (3, 2, 2, '2022-01-03', '2022-02-03');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (9, 3, 6, '2022-01-21', '2022-02-21');


