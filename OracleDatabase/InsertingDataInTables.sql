-- Inserting into PUBLISHER table
INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('T. Egerton, Whitehall', '10 Whitehall, London SW1A 2DY, UK', '+44 20 1234 5678');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('Secker & Warburg', '20 Vauxhall Bridge Rd, London SW1V 2SA, UK', '+44 20 1234 5678');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('Charles Scribner''s Sons', '123 Main St, New York, NY 10001', '212-555-1234');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('Editorial Sudamericana', 'Av. Pueyrredón 1459, Buenos Aires, Argentina', '+54 11 4802-7777');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('George Allen & Unwin', '40 Museum St, London WC1A 1LU, UK', '+44 20 1234 5678');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('Scholastic Press', '557 Broadway, New York, NY 10012, USA', '+1 212-343-6100');

INSERT INTO denise.publisher (publisher_name, address, phone)
VALUES ('Little, Brown and Company', '1290 Avenue of the Americas, New York, NY 10104, USA', '+1 (212) 364-1120');

SELECT * FROM denise.publisher;

-- Inserting into BOOK table
INSERT INTO denise.book (title, publisher_name) VALUES
    ('The Catcher in the Rye', 'Little, Brown and Company');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('To Kill a Mockingbird', 'HarperCollins');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('1984', 'Secker & Warburg');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('Animal Farm', 'Secker & Warburg');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('Pride and Prejudice', 'T. Egerton, Whitehall');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('The Great Gatsby', 'Charles Scribner''s Sons');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('One Hundred Years of Solitude', 'Editorial Sudamericana');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('The Lord of the Rings', 'George Allen & Unwin');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('The Hobbit', 'George Allen & Unwin');
INSERT INTO denise.book (title, publisher_name) VALUES
    ('The Hunger Games', 'Scholastic Press');

SELECT * FROM denise.book;


-- Inserting into BOOK_AUTHORS table
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (1, 'J.D. Salinger');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (2, 'Harper Lee');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (3, 'George Orwell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (4, 'George Orwell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (5, 'Jane Austen');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (6, 'F. Scott Fitzgerald');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (7, 'Gabriel García Márquez');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (8, 'J.R.R. Tolkien');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (9, 'J.R.R. Tolkien');
INSERT INTO denise.book_authors (book_id, author_name) VALUES
    (10, 'Suzanne Collins');

SELECT * FROM denise.book_authors;


-- Inserting into LIBRARY_BRANCH table
INSERT INTO denise.library_branch (branch_name, address) VALUES
    ('Central Library', '123 Main St.');
INSERT INTO denise.library_branch (branch_name, address) VALUES
    ('North Branch', '456 North St.');
INSERT INTO denise.library_branch (branch_name, address) VALUES
    ('South Branch', '789 South St.');

SELECT * FROM denise.library_branch;


-- Inserting into BOOK_COPIES table
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (1, 1, 3);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (2, 1, 2);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (3, 1, 5);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (3, 2, 3);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (4, 1, 4);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (5, 2, 2);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (6, 1, 1);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (7, 2, 2);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (8, 1, 5);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (9, 1, 2);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (9, 3, 3);
INSERT INTO denise.book_copies (book_id, branch_id, no_of_copies) VALUES
    (10, 3, 1);

SELECT * FROM denise.book_copies;

-- Inserting into BORROWER table
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('John Doe', '456 Elm St.', '555-1234');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Jane Smith', '789 Oak St.', '555-5678');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Bob Johnson', '321 Pine St.', '555-9012');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Samantha Lee', '654 Maple St.', '555-3456');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('David Brown', '987 Cedar St.', '555-7890');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Emily Davis', '246 Walnut St.', '555-2345');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Chris Wilson', '369 Birch St.', '555-6789');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Amanda Clark', '159 Chestnut St.', '555-0123');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Mark Taylor', '753 Spruce St.', '555-4567');
INSERT INTO denise.borrower (person_name, address, phone) VALUES
    ('Karen Adams', '852 Fir St.', '555-8901');

SELECT * FROM denise.borrower;

-- Inserting into BOOK_LOANS table
INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 1, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (7, 2, 1, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (3, 2, 1, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-03-03', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (2, 1, 1, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-03-29', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (9, 1, 2, TO_DATE('2022-01-03', 'YYYY-MM-DD'), TO_DATE('2022-02-03', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (10, 3, 8, TO_DATE('2022-01-30', 'YYYY-MM-DD'), TO_DATE('2022-03-02', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (7, 2, 9, TO_DATE('2022-02-22', 'YYYY-MM-DD'), TO_DATE('2022-03-22', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (6, 1, 10, TO_DATE('2022-02-15', 'YYYY-MM-DD'), TO_DATE('2022-03-17', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 8, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 7, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

INSERT INTO denise.book_loans(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 6, TO_DATE('2022-01-21', 'YYYY-MM-DD'), TO_DATE('2022-02-21', 'YYYY-MM-DD'));

SELECT * FROM denise.book_loans;

	