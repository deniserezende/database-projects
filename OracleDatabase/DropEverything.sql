
-- Drop all tables
BEGIN
  FOR cur_rec IN (SELECT object_name, object_type
                  FROM user_objects
                  WHERE object_type IN ('TABLE', 'VIEW'))
  LOOP
    BEGIN
      IF cur_rec.object_type = 'TABLE' THEN
        EXECUTE IMMEDIATE ('DROP TABLE ' || cur_rec.object_name || ' CASCADE CONSTRAINTS');
      ELSE
        EXECUTE IMMEDIATE ('DROP VIEW ' || cur_rec.object_name);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error dropping ' || cur_rec.object_name || ': ' || SQLERRM);
    END;
  END LOOP;
END;

COMMIT;
/

-- DELETE FROM BOOK_COPIES_INDIVIDUAL;
-- TRUNCATE TABLE BOOK;
-- DROP TABLE BOOK CASCADE CONSTRAINTS;


-- Drop all routines
BEGIN
    FOR routine IN (SELECT object_name, object_type FROM all_objects WHERE owner = 'DENISE' AND object_type IN ('PROCEDURE', 'FUNCTION'))
    LOOP
        EXECUTE IMMEDIATE 'DROP ' || routine.object_type || ' DENISE.' || routine.object_name;
    END LOOP;
END;
/

-- Drop Materialized View
-- DROP MATERIALIZED VIEW '[NAME]'; -- MONTH_BORROWERS
-- COMMIT;


