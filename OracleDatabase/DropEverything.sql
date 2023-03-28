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
