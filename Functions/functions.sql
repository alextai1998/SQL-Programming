CREATE FUNCTION product(a INTEGER, b INTEGER)
  RETURNS INTEGER AS
  $$
  BEGIN
   RETURN a * b;
  END;
  $$ LANGUAGE plpgsql;

SELECT * FROM product(4, 5);

-- create fibonacci function recursive
CREATE FUNCTION fibo(num_terms INTEGER)
  RETURNS INTEGER AS
  $$
  BEGIN
    IF num_terms < 2 THEN
      RETURN num_terms;
    ELSE
      RETURN fibo(num_terms-2) + fibo(num_terms-1);
    END IF;
  END;
  $$ LANGUAGE plpgsql;

SELECT fibo(6);

-- create camel function
DROP FUNCTION IF EXISTS camelCase(a TEXT, b TEXT);
CREATE FUNCTION camelCase(a TEXT, b TEXT)
  RETURNS TEXT AS
$$
BEGIN
  RETURN CONCAT(INITCAP(a), INITCAP(b));
END;
$$ LANGUAGE plpgsql;

SELECT camelCase('alex', 'tai');

-- create email function
DROP FUNCTION IF EXISTS email(firstname TEXT, lastname TEXT, dmn TEXT);
CREATE FUNCTION email(firstname TEXT, lastname TEXT, dmn TEXT DEFAULT '@pas.org')
  RETURNS TEXT AS
$$
BEGIN
    RETURN CONCAT(LOWER(SUBSTRING(firstname, 1, 1)), '.',  LOWER(lastname), dmn);
END;
$$ LANGUAGE plpgsql;

SELECT email('Alex', 'Tai');

-- create MIMO function
DROP FUNCTION IF EXISTS myMIMO(a INTEGER, b INTEGER, c INTEGER);
CREATE FUNCTION myMIMO(a INTEGER,
                       b INTEGER,
                       c INTEGER,
                       OUT total INTEGER,
                       OUT maxi INTEGER) AS
$$
BEGIN
  total := a + b + c;
  maxi := GREATEST(a, b, c);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM myMIMO(2, 4, 5);

-- create getname function
DROP FUNCTION IF EXISTS getname(fname TEXT, email TEXT);
CREATE FUNCTION getname(fname TEXT,
                        email TEXT,
                        OUT dmn TEXT,
                        OUT lastname TEXT,
                        OUT firstname TEXT) AS
$$
BEGIN
  firstname := fname;
  dmn = split_part(email, '@', 2);
  lastname = INITCAP(split_part(split_part(email,'.', 2),'@' ,1));
END;
$$ LANGUAGE plpgsql;

SELECT * FROM getname('Alex', email('alex', 'tai', '@gmail.com'));

DROP FUNCTION IF EXISTS public.ave_total(NUMERIC[]);
CREATE FUNCTION ave_total(Variadic inputs NUMERIC [], OUT total INTEGER, OUT average FLOAT) AS
$$
DECLARE
  r INTEGER;
  num INTEGER;
BEGIN
  total := 0;
  average := 0;
  num := 0;
  FOR r IN SELECT unnest(inputs)
  LOOP
    total := total + r;
    num := num + 1;
  END LOOP;
  average := total / num;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM Ave_Total(2, 4, 6, 8);

