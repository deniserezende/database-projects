INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('T. Egerton, Whitehall', '10 Whitehall, London SW1A 2DY, UK', '+44 20 1234 5678');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('HarperCollins', '195 Broadway, New York, NY 10007', '212-207-7000');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('Secker & Warburg', '20 Vauxhall Bridge Rd, London SW1V 2SA, UK', '+44 20 1234 5678');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('Charles Scribner''s Sons', '123 Main St, New York, NY 10001', '212-555-1234');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('Editorial Sudamericana', 'Av. Pueyrredón 1459, Buenos Aires, Argentina', '+54 11 4802-7777');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('George Allen & Unwin', '40 Museum St, London WC1A 1LU, UK', '+44 20 1234 5678');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('Scholastic Press', '557 Broadway, New York, NY 10012, USA', '+1 212-343-6100');

INSERT INTO "LIBRARY".PUBLISHER (publisher_name, address, phone)
VALUES ('Little, Brown and Company', '1290 Avenue of the Americas, New York, NY 10104, USA', '+1 (212) 364-1120');

SELECT * FROM "LIBRARY".PUBLISHER;

-- Inserting into BOOK table
INSERT INTO "LIBRARY".BOOK (title, publisher_name) VALUES
    ('The Catcher in the Rye', 'Little, Brown and Company'),
    ('To Kill a Mockingbird', 'HarperCollins'),
    ('1984', 'Secker & Warburg'),
    ('Animal Farm', 'Secker & Warburg'),
    ('Pride and Prejudice', 'T. Egerton, Whitehall'),
    ('The Great Gatsby', 'Charles Scribner''s Sons'),
    ('One Hundred Years of Solitude', 'Editorial Sudamericana'),
    ('The Lord of the Rings', 'George Allen & Unwin'),
    ('The Hobbit', 'George Allen & Unwin'),
    ('The Hunger Games', 'Scholastic Press');
	
SELECT * FROM "LIBRARY".BOOK;

-- Inserting into BOOK_AUTHORS table
INSERT INTO "LIBRARY".BOOK_AUTHORS (book_id, author_name) VALUES
    (1, 'J.D. Salinger'),
    (2, 'Harper Lee'),
    (3, 'George Orwell'),
    (4, 'George Orwell'),
    (5, 'Jane Austen'),
    (6, 'F. Scott Fitzgerald'),
    (7, 'Gabriel García Márquez'),
    (8, 'J.R.R. Tolkien'),
    (9, 'J.R.R. Tolkien'),
    (10, 'Suzanne Collins');

-- Inserting into LIBRARY_BRANCH table
INSERT INTO "LIBRARY".LIBRARY_BRANCH (branch_name, address) VALUES
    ('Central Library', '123 Main St.'),
    ('North Branch', '456 North St.'),
    ('South Branch', '789 South St.');

-- Inserting into BOOK_COPIES table
INSERT INTO "LIBRARY".BOOK_COPIES (book_id, branch_id, no_of_copies) VALUES
    (1, 1, 3),
    (2, 1, 2),
    (3, 1, 5),
    (3, 2, 3),
    (4, 1, 4),
    (5, 2, 2),
    (6, 1, 1),
    (7, 2, 2),
    (8, 1, 5),
    (9, 1, 2),
    (9, 3, 3),
    (10, 3, 1);
	
SELECT * FROM "LIBRARY".BOOK_COPIES;

-- Inserting into BORROWER table
INSERT INTO "LIBRARY".BORROWER (person_name, address, phone) VALUES
    ('John Doe', '456 Elm St.', '555-1234'),
    ('Jane Smith', '789 Oak St.', '555-5678'),
    ('Bob Johnson', '321 Pine St.', '555-9012'),
    ('Samantha Lee', '654 Maple St.', '555-3456'),
    ('David Brown', '987 Cedar St.', '555-7890'),
    ('Emily Davis', '246 Walnut St.', '555-2345'),
    ('Chris Wilson', '369 Birch St.', '555-6789'),
    ('Amanda Clark', '159 Chestnut St.', '555-0123'),
    ('Mark Taylor', '753 Spruce St.', '555-4567'),
    ('Karen Adams', '852 Fir St.', '555-8901');
	
SELECT * FROM "LIBRARY".BORROWER;

-- Inserting into BOOK_LOANS table
INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 1, '2022-01-21', '2022-02-21');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (7, 2, 1, '2022-01-21', '2022-02-21');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (3, 2, 1, '2022-01-21', '2022-03-03');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (2, 1, 1, '2022-01-21', '2022-03-29');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (9, 1, 2, '2022-01-03', '2022-02-03');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (10, 3, 8, '2022-01-30', '2022-03-02');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (7, 2, 9, '2022-02-22', '2022-03-22');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (6, 1, 10, '2022-02-15', '2022-03-17');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 8, '2022-01-21', '2022-02-21');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 7, '2022-01-21', '2022-02-21');

INSERT INTO "LIBRARY".BOOK_LOANS(book_id, branch_id, card_no, date_out, due_date)
VALUES (8, 1, 6, '2022-01-21', '2022-02-21');

SELECT * FROM "LIBRARY".BOOK_LOANS;

	