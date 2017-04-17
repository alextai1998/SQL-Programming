------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
----------------------------------- Task #1: Create the following tables and functions ---------------------------------
----------------------------------- Tables: domain, category, students, grades -----------------------------------------
----------------------------------- Functions: setEmail, getLetter -----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP TABLE IF EXISTS students, grades, domain, category;
DROP FUNCTION IF EXISTS setEmail(firstname TEXT, lastname TEXT, dmn TEXT);
DROP FUNCTION IF EXISTS getLetter(grades INT);

CREATE TABLE IF NOT EXISTS domain(
  domain_id SERIAL PRIMARY KEY,
  domain_sufix VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS category(
  category_id SERIAL PRIMARY KEY,
  category_name VARCHAR(50),
  domain_id INT NOT NULL,

  FOREIGN KEY (domain_id) REFERENCES domain(domain_id)
);

CREATE TABLE IF NOT EXISTS students(
  student_id SERIAL PRIMARY KEY,
  firstname VARCHAR(50),
  lastname VARCHAR(50),
  category_id INTEGER,
  email VARCHAR(50),
  created TIMESTAMP,

  FOREIGN KEY (category_id) REFERENCES category(category_id)
);

CREATE TABLE IF NOT EXISTS grades(
  grade_id SERIAL PRIMARY KEY,
  student_id INT NOT NULL,
  score INTEGER,
  scoreLetter VARCHAR(5),
  date TIMESTAMP,

  FOREIGN KEY (student_id) REFERENCES students(student_id)
);

CREATE FUNCTION setEmail(firstname TEXT, lastname TEXT, dmn TEXT DEFAULT 'pas.org')
  RETURNS TEXT AS
  $$
  BEGIN
    RETURN CONCAT(LOWER(SUBSTRING(firstname, 1, 1)), '.',  LOWER(lastname), '@', dmn);
  END;
  $$ LANGUAGE plpgsql;

CREATE FUNCTION getLetter(grades INT)
  RETURNS VARCHAR(5) AS
  $$
  BEGIN
    IF 100 >= grades AND grades >= 90 THEN
      RETURN 'A';
    ELSEIF 89 >= grades AND grades >= 80 THEN
      RETURN 'B';
    ELSEIF 79 >= grades AND grades >= 70 THEN
      RETURN 'C';
    ELSEIF 69 >= grades AND grades >= 60 THEN
      RETURN 'D';
    ELSEIF 59 >= grades AND grades >= 0 THEN
      RETURN 'F';
    ELSE
      RETURN 'Invalid Number';
    END IF;
  END;
  $$ LANGUAGE plpgsql;
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------- Task #2: Create a function that can insert ------------------------------------------
---------------------------------- new people in the student table with email. -----------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS newPerson (firstname VARCHAR(30), lastname VARCHAR(30), role VARCHAR(30));

CREATE FUNCTION newPerson(firstname VARCHAR(30), lastname VARCHAR(30), role VARCHAR(30))
  RETURNS VOID AS
  $$
  DECLARE
    str VARCHAR(20);
  BEGIN
    str := CONCAT(LOWER(role), '.pas.org') ;
    INSERT INTO students(firstname,
                         lastname,
                         email,
                         created) VALUES (firstname,
                                          lastname,
                                          setEmail(firstname, lastname, str),
                                          current_date);
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM newPerson('Alex', 'Tai', 'Student');
SELECT * FROM newPerson('Jason', 'Lin', 'Student');
SELECT * FROM students;
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------- Task #3: Create a function that can insert ------------------------------------------
---------------------------------- multiple grades with a single query. ------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS insertMulGrades (id INTEGER, date DATE, VARIADIC inputs NUMERIC[]);

CREATE FUNCTION insertMulGrades(id INTEGER, date DATE, VARIADIC inputs NUMERIC[])
  RETURNS VOID AS
  $$
  DECLARE
    sum INTEGER; -- sum of all numbers
    cnt INTEGER; -- counter of numbers
    grade INTEGER; -- each number
  BEGIN
    cnt := 0;
    sum := 0;
    FOR grade IN SELECT unnest(inputs)
      LOOP
        INSERT INTO grades(student_id, score, scoreLetter, date) VALUES (id, grade, getLetter(grade), date);
      END LOOP;
    RAISE NOTICE 'The id is %, the date is %', id, date;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM insertMulGrades(1, '17/04/2017', 70, 80, 90, 60, 50);
SELECT * FROM insertMulGrades(2, '17/04/2017', 100, 100, 100, 100, 95);
SELECT * FROM grades;
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------- Task #4: Create a function that can display -----------------------------------------
---------------------------------- a student's average to a specified date. --------------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS average (id INTEGER, date DATE);

CREATE FUNCTION average(id INTEGER, dte DATE)
  RETURNS TABLE(
    score VARCHAR(2),
    sName VARCHAR(60)
  ) AS
  $$
  DECLARE
    sum INTEGER := 0; -- sum of all numbers
    cnt INTEGER := 0; -- counter of numbers
    grade INTEGER := 0; -- each number
    fname VARCHAR(30); -- student first name
    lname VARCHAR(30); -- student last name
  BEGIN
    FOR grade in SELECT grades.score FROM grades WHERE grades.date <= dte AND student_id = id
      LOOP
        sum := sum + grade;
        cnt := cnt + 1;
      END LOOP;

    SELECT firstname INTO fname FROM students WHERE student_id = id;
    SELECT lastname INTO lname FROM students WHERE student_id = id;

    score := getLetter(sum/cnt);
    sName := CONCAT(fname, ' ', lname);

    RAISE NOTICE '% % had an average score of % to the date %', fname, lname, score, dte;

    RETURN NEXT;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM average(1, '17/04/2017');
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------- Task #5.1: Create a function to present to class ------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS popstdev (VARIADIC inputs NUMERIC[]);

CREATE OR REPLACE FUNCTION popstdev(VARIADIC inputs NUMERIC[])
  RETURNS TABLE(
    std VARCHAR(2),
    popMean DECIMAL
  ) AS
$$
DECLARE
  sum DECIMAL := 0; -- sum of all numbers
  diffsqrd DECIMAL := 0; -- square of the inputs minus the mean
  sum2 DECIMAL := 0; -- sum of all diffsqrd
  mean DECIMAL := 0; -- average of all the inputs
  cnt DECIMAL := 0; -- counter of numbers
  cnt2 DECIMAL := 0; -- 2nd counter of numbers
  num DECIMAL := 0; -- each number
BEGIN
  FOR num IN SELECT unnest(inputs)
  LOOP
    sum := sum + num;
    cnt := cnt + 1;
  END LOOP;

  popMean := sum/cnt;

  FOR num IN SELECT unnest(inputs)
  LOOP
    diffsqrd := (num - popMean)^2;
    sum2 := sum2 + diffsqrd;
    cnt2 := cnt2 + 1;
  END LOOP;

  std := |/(sum2/cnt2);

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM popstdev(70, 80, 90, 60, 50);
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
---------------------------------- Task #5.2: Create a function to demonstrate -----------------------------------------
------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
DROP FUNCTION IF EXISTS popstdev2 (id INTEGER, date DATE);

CREATE FUNCTION popstdev2(id INTEGER, dte DATE)
  RETURNS TABLE(
    std VARCHAR(2),
    sName VARCHAR(60),
    popMean DECIMAL
  ) AS
$$
DECLARE
  sum DECIMAL := 0; -- sum of all numbers
  sum2 DECIMAL := 0; -- sum of all grades subtract mean
  diff DECIMAL := 0; -- sum of all numbers
  mean DECIMAL := 0; -- sum of all numbers
  cnt DECIMAL := 0; -- counter of numbers
  cnt2 DECIMAL := 0; -- 2nd counter of numbers
  grade DECIMAL := 0; -- each number
  fname VARCHAR(30); -- student first name
  lname VARCHAR(30); -- student last name
BEGIN
  FOR grade in SELECT grades.score FROM grades WHERE grades.date <= dte AND student_id = id
  LOOP
    sum := sum + grade;
    cnt := cnt + 1;
  END LOOP;

  SELECT firstname INTO fname FROM students WHERE student_id = id;
  SELECT lastname INTO lname FROM students WHERE student_id = id;

  popMean := sum/cnt;

  FOR grade in SELECT grades.score FROM grades WHERE grades.date <= dte AND student_id = id
  LOOP
    diff := (grade - popMean)^2;
    sum2 := sum2 + diff;
    cnt2 := cnt2 + 1;
  END LOOP;

  sName := CONCAT(fname, ' ', lname);
  std := |/(sum2/cnt2);

  RETURN NEXT;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM popstdev2(1, '17/04/2017');
