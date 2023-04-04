-- 3. Write a procedure to detect and reconcile authors who have inconsistent entries in the book
-- authors table. This procedure is an example of entity matching, which is a complex task but will be
-- quite simplified for this exercise.
-- Assume that authors can have inconsistent entries due to typos
-- (e.g., John Joseph Powell and John Joseph Powel) or
-- abbreviations (e.g., John Joseph Powell and John J. Powell). Assume also that
-- typos are constrained to at most two non-matching characters. This contraint allows detecting
-- missing (e.g., Powel) or exceeding caracters (e.g., Poweell), and character switches (e.g., Pwoell).
-- Also, assume that author names are either: i) given name, middle name, and surname (e.g., John
-- Joseph Powell); or ii) given name, middle initial, and surname (e.g., John J. Powell). Duplicates
-- regarding middle name or middle initial must match the first letter (i.e., John Joseph Powell and
-- John A. Powell are not duplicates).
-- The procedure should:
-- • detect duplicates;
-- • identify the most frequent between the duplicated values and eliminate the duplication by
-- updating the least frequent value with the most frequent one (e.g., if there is 5 occurrences of
-- John J. Powell in the database and only one occurrence of John J. Pwoell, then the procedure
-- should update John J. Pwoell to John J. Powell);
-- • log every duplicate elimination, saving the book id, the old author name, the new author
-- name, and the update timestamp to a log table.
-- Notice that your procedure implementation can rely on cursors, call built-in or user-defined
-- functions, use triggers, etc. Use the DBMS resources as needed. Submit a script containing all
-- statements needed to implement and test the procedure (i.e., the script should include proper data
-- insertions to test the procedure).

-- Creating the equivalent to levenshtein function
CREATE OR REPLACE FUNCTION levenshtein(stringOne VARCHAR2, stringTwo VARCHAR2)
RETURN NUMBER
IS
BEGIN
  RETURN UTL_MATCH.EDIT_DISTANCE(stringOne, stringTwo);
END;
/


-- Creating log table to register changes in book author
-- Attributes: log_id, book_id, old_name, new_name, timestamp
-- DROP TABLE "LIBRARY".log_book_author_changes;
CREATE TABLE denise.log_book_author_changes (
    log_id NUMBER GENERATED ALWAYS AS IDENTITY NOT NULL,
    book_id INTEGER NOT NULL,
    old_name VARCHAR2(255) NOT NULL,
    new_name VARCHAR2(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT pk_log_id PRIMARY KEY(log_id)
);





-- parei aqui:
-- Create function to determine if name should be changed (normalized)
CREATE OR REPLACE FUNCTION names_should_be_normalized
    (fullNameOne VARCHAR2, fullNameTwo VARCHAR2)
    RETURN BOOLEAN IS
    authorOne_first_name VARCHAR2(100);
    authorOne_middle_name VARCHAR2(100);
    authorOne_last_name VARCHAR2(100);
    authorTwo_first_name VARCHAR2(100);
    authorTwo_middle_name VARCHAR2(100);
    authorTwo_last_name VARCHAR2(100);

    no_characters_diff_first INT := 0;
    no_characters_diff_middle INT := 0;
    no_characters_diff_last INT := 0;
    no_characters_diff INT := 0;
    max_diff INT := 2;
BEGIN
    -- Separating first name, middle name, and last name for both authors
    SELECT
        REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 1),
        CASE WHEN REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 3) IS NOT NULL
           THEN REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 2)
        END,
        CASE WHEN REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 3) IS NOT NULL
           THEN REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 3)
           ELSE REGEXP_SUBSTR(fullNameOne, '[^ ]+', 1, 2)
        END
    INTO
        authorOne_first_name, authorOne_middle_name, authorOne_last_name
    FROM dual;


    SELECT
        REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 1),
        CASE WHEN REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 3) IS NOT NULL
           THEN REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 2)
        END,
        CASE WHEN REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 3) IS NOT NULL
           THEN REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 3)
           ELSE REGEXP_SUBSTR(fullNameTwo, '[^ ]+', 1, 2)
        END
    INTO
        authorTwo_first_name, authorTwo_middle_name, authorTwo_last_name
    FROM dual;

    -- Checking if both authors have the same amount of names
    -- If not return false and if true continue
    IF ((authorOne_middle_name IS NOT NULL AND authorTwo_middle_name IS NULL)
        OR (authorOne_middle_name IS NULL AND authorTwo_middle_name IS NOT NULL)
        OR (authorOne_last_name IS NOT NULL AND authorTwo_last_name IS NULL)
        OR (authorOne_last_name IS NULL AND authorTwo_last_name IS NOT NULL)) THEN
        DBMS_OUTPUT.PUT_LINE('Authors don''t have the same amount of names');
        RETURN FALSE;
    END IF;


    -- Checking if first name is equal or with typo
    no_characters_diff_first := levenshtein(lower(authorOne_first_name), lower(authorTwo_first_name));

    -- Checking if middle name is in the format A. (e.g.)
    IF (length(authorOne_middle_name) > 2) THEN
        no_characters_diff_middle := levenshtein(lower(authorOne_middle_name), lower(authorTwo_middle_name));
    ELSE
        IF (SUBSTR(SUBSTR(authorOne_middle_name, 1, 2), 2, 1) = '.') THEN
            -- debug
            --DBMS_OUTPUT.PUT_LINE('Second character is a dot');
            -- Checking if the First letter is the same
            IF (SUBSTR(authorOne_middle_name, 1, 1) = SUBSTR(authorTwo_middle_name, 1, 1)) THEN
                -- debug
                DBMS_OUTPUT.PUT_LINE('First letters are the same');
                -- continue
            ELSE
                RETURN FALSE;
            END IF;
        END IF;
    END IF;

    -- Checking if last name is equal or with typo
    no_characters_diff_last := utl_match.edit_distance(lower(authorOne_last_name), lower(authorTwo_last_name));

    -- Sum of all diff
    no_characters_diff := no_characters_diff + no_characters_diff_first + no_characters_diff_middle + no_characters_diff_last;

    -- If more than 2 differences, return false else continue
    IF(no_characters_diff > max_diff) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;



CREATE OR REPLACE PROCEDURE fix_author_name_bugs AS
    author denise.book_authors %ROWTYPE;
    distinct_author denise.book_authors %ROWTYPE;
    amountOne INT;
    amountTwo INT;
    book_id_temp INT;
    most_frequent VARCHAR2(200);
    less_frequent VARCHAR2(200);
    v_log_count NUMBER;
    log_timestamp TIMESTAMP NULL;
BEGIN
    DBMS_OUTPUT.PUT_LINE('beginning');
    FOR author IN (SELECT DISTINCT author_name, book_id FROM denise.book_authors) LOOP
        FOR distinct_author IN (SELECT DISTINCT author_name, book_id FROM denise.book_authors WHERE author_name <> author.author_name) LOOP
            -- Debug
            DBMS_OUTPUT.PUT_LINE('% author=' || author.author_name || ' distinct_author=' || distinct_author.author_name);

            -- Checking if author name should be corrected
            IF names_should_be_normalized(author.author_name, distinct_author.author_name) THEN
                DBMS_OUTPUT.PUT_LINE('Should normalize: author=' || author.author_name || ' distinct_author=' || distinct_author.author_name);

                -- Getting the most frequent one
                SELECT COUNT(*) INTO amountOne FROM denise.book_authors WHERE author_name = author.author_name;
                SELECT COUNT(*) INTO amountTwo FROM denise.book_authors WHERE author_name = distinct_author.author_name;
                IF amountOne > amountTwo THEN
                    most_frequent := author.author_name;
                    less_frequent := distinct_author.author_name;
                    book_id_temp := distinct_author.book_id;
                ELSE
                    most_frequent := distinct_author.author_name;
                    less_frequent := author.author_name;
                    book_id_temp := author.book_id;
                END IF;
                -- debug
                -- DBMS_OUTPUT.PUT_LINE('author_name most frequent ' || most_frequent);
                DBMS_OUTPUT.PUT_LINE('author_name less frequent ' || less_frequent);

                -- Generating Log: Inserting in log table
                -- BUG: inserting multiple times in log
                INSERT INTO denise.log_book_author_changes (book_id, old_name, new_name)
                VALUES (book_id_temp, less_frequent, most_frequent);

                -- Updating the least frequent
                UPDATE denise.book_authors
                SET author_name = most_frequent
                WHERE author_name = less_frequent;
            END IF;
        END LOOP;
    END LOOP;
END;




    -- funcao para normalizar os nomes e colocar no log
    -- For for ->
    -- select todos os autors distinct
    -- determinar o mais frequente guarda o nome mais frequente
    -- select todos os autors distinct - um (o mais frequente por exemplo)
    -- chama uma funcao que determina os nomes parecidos
    -- no fim add no log

CALL fix_author_name_bugs();

SELECT * FROM denise.book;
SELECT * FROM denise.book_authors;
SELECT * FROM denise.log_book_author_changes;


-- DATA TO TEST EXERCISE THREE:
INSERT INTO denise.publisher(publisher_name) VALUES('Publisher 1');

INSERT INTO denise.book (title, publisher_name) VALUES ('Book 1', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 2', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 3', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 4', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 5', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 6', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 7', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 8', 'Publisher 1');
INSERT INTO denise.book (title, publisher_name) VALUES ('Book 9', 'Publisher 1');

SELECT * FROM denise.book;

-- Verificar book_id inserido em cima
INSERT INTO denise.book_authors (book_id, author_name) VALUES (11, 'John Joseph Powell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (12, 'John J. Powell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (13, 'John Joseph Powel');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (14, 'John Joseph Powel');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (15, 'John Joseph Powel');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (16, 'John Joseph Powell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (17, 'John Joseph Powell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (18, 'John Joseph Powell');
INSERT INTO denise.book_authors (book_id, author_name) VALUES (19, 'John Joseph Powell');

SELECT * FROM denise.book_authors;
