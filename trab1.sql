-- Primeiro preciso criar uma tabela com base no esquema final da descrição


-- 1. Create a materialized view month_borrowers that shows the data 
-- (card_no, name, address, and phone) from the borrowers who had (or have) 
-- more than one loan whose length (i.e., the difference between the date out 
-- and the due date) is greater than or equal to 30 days. The view should also 
-- show the loan length, the book title and the branch name of these loans. 
-- Besides, perform updates to the base tables, eventually run statements to make 
-- the DBMS update the view, and show the state of the up-to-date materialized view.

