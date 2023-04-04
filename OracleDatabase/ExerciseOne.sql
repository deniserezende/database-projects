-- 1. Create a materialized view month_borrowers that shows the data (card_no, name, address, and phone)
-- from the borrowers who had (or have) more than one loan whose length (i.e., the difference between the
-- date out and the due date) is greater than or equal to 30 days. The view should also show the loan length,
-- the book title and the branch name of these loans.
-- Besides, perform updates to the base tables, eventually run statements to make the DBMS update the view,
-- and show the state of the up-to-date materialized view.

-- DROP MATERIALIZED VIEW denise.month_borrowers;
CREATE MATERIALIZED VIEW denise.month_borrowers
BUILD IMMEDIATE
REFRESH ON DEMAND
AS SELECT
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
        (SELECT
            borrower_.card_no,
            borrower_.person_name,
            borrower_.address,
            borrower_.phone,
            COUNT(*) as num_loans
            FROM denise.borrower borrower_
            JOIN denise.book_loans book_loans_ ON book_loans_.card_no = borrower_.card_no
            -- Only include rows where the loan length is greater than or equal to 30 days
            WHERE
            book_loans_.due_date - book_loans_.date_out >= 30
            -- Group the results by borrower and book information columns
            GROUP BY
            borrower_.card_no, borrower_.person_name, borrower_.address, borrower_.phone
            -- Only include groups where the borrower has had more than one loan with a loan length greater than or equal to 30 days
            HAVING COUNT(*) > 1
            ORDER BY
            borrower_.card_no
    ) t1

    JOIN
        (SELECT
            -- Select book loan information columns from "book_loans" table
            book_loans_.book_id,
            book_loans_.branch_id,
            book_loans_.date_out,
            book_loans_.due_date,
            book_loans_.card_no
            FROM denise.book_loans book_loans_
            -- Only include rows where the loan length is greater than or equal to 30 days
            WHERE book_loans_.due_date - book_loans_.date_out >= 30
        ) t2
    ON t1.card_no = t2.card_no

    JOIN
        (SELECT
            book_.book_id,
            book_.title
            FROM
            denise.book book_
        ) t3
    ON t3.book_id = t2.book_id

    JOIN
        (SELECT
            library_branch_.branch_id,
            library_branch_.branch_name
            FROM
            denise.library_branch library_branch_
        ) t4
    ON t4.branch_id = t2.branch_id

    ORDER BY
    t1.card_no;

SELECT * FROM denise.month_borrowers;



-- DATA TO TEST EXERCISE ONE:
SELECT * FROM denise.month_borrowers;

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (3, 2, 2, TO_DATE('2022-01-03', 'YYYY-MM-DD'), TO_DATE('2022-02-03', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (9, 3, 6, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

-- DELETE FROM denise.book_loans
-- WHERE book_id = 9 AND branch_id = 3 AND card_no = 6 AND date_out = TO_DATE('2022-01-21', 'YYYY-MM-DD')
-- AND due_date = TO_DATE('2022-02-21', 'YYYY-MM-DD');

EXECUTE DBMS_MVIEW.REFRESH('denise.month_borrowers');

SELECT * FROM denise.month_borrowers;
