CREATE TABLE tv_series(
  tv_series_id SERIAL PRIMARY KEY,
  title_series VARCHAR(50),
  year VARCHAR(50),
  language VARCHAR(50),
  budget BIGINT
);

CREATE TABLE actor(
  actor_id SERIAL PRIMARY KEY,
  firstName VARCHAR(50) ,
  lastName VARCHAR(50) ,
  nationality VARCHAR(50)
);

CREATE TABLE network(
  network_id SERIAL PRIMARY KEY,
  name_network VARCHAR(50) ,
  location VARCHAR(50)
);

CREATE TABLE award(
  award_id SERIAL PRIMARY KEY,
  category VARCHAR(50) ,
  organize VARCHAR(50)
);

CREATE TABLE starrIn(
  actor_id INT,
  tv_series_id INT,
  FOREIGN KEY (actor_id) REFERENCES actor,
  FOREIGN KEY (tv_series_id) REFERENCES tv_series
);

CREATE TABLE featureIn(
  tv_series_id INT,
  network_id INT,
  FOREIGN KEY (tv_series_id) REFERENCES tv_series,
  FOREIGN KEY  (network_id) REFERENCES network
);

CREATE TABLE awards_tvseries(
  award_id INT,
  tv_series_id INT,
  FOREIGN KEY (award_id) REFERENCES award,
  FOREIGN KEY (tv_series_id) REFERENCES tv_series
);

DROP TABLE formSeriesNetwork;
DROP TABLE formActors_Series;
DROP TABLE formAwards_Series;

CREATE TEMPORARY TABLE formSeriesNetwork(
  title_series VARCHAR(50),
  year VARCHAR(50),
  language VARCHAR(50),
  budget BIGINT,
  name_network VARCHAR(50),
  location VARCHAR(50)
);

CREATE TEMPORARY TABLE formActors_Series(
  firstName VARCHAR(50) ,
  lastName VARCHAR(50) ,
  nationality VARCHAR(50),
  title_series VARCHAR(50),
  year VARCHAR(50),
  language VARCHAR(50),
  budget BIGINT
);

CREATE TEMPORARY TABLE formAwards_Series(
  category VARCHAR(50),
  organize VARCHAR(50),
  title_series VARCHAR(50),
  year VARCHAR(50),
  language VARCHAR(50),
  budget BIGINT
);


------------------------------------------------------------------------------------------------------------------------


-- SELECT * FROM pg_catalog.pg_tables
-- WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema'; */


------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION fillForm()
  RETURNS TRIGGER AS
$emp_trigger$
DECLARE id_series INTEGER;
DECLARE id_network INTEGER;
BEGIN
  IF NOT EXISTS (SELECT network_id FROM network WHERE name_network = NEW.name_network)
  THEN
    INSERT INTO network (name_network, location)
    VALUES (NEW.name_network, NEW.location);
  END IF;

  IF NOT EXISTS (SELECT tv_series_id FROM tv_series WHERE title_series = NEW.title_series)
  THEN
    INSERT INTO tv_series (title_series, year, language, budget)
      VALUES (NEW.title_series, NEW.year, NEW.language, NEW.budget);
  END IF;

  id_series:= 0;
  id_network:= 0;
  SELECT tv_series_id INTO id_series FROM tv_series WHERE
    title_series = NEW.title_series AND year = NEW.year AND budget = NEW.budget AND language = NEW.language;
  SELECT network_id INTO id_network FROM network WHERE name_network = NEW.name_network AND location = NEW.location;

   INSERT INTO featureIn (tv_series_id, network_id)
    VALUES (id_series, id_network);
  RETURN NEW;
END;
$emp_trigger$ LANGUAGE plpgsql;


CREATE TRIGGER triggerFillForm
  BEFORE INSERT
  ON formSeriesNetwork
FOR EACH ROW EXECUTE PROCEDURE fillForm();


------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION actor_insertion()
  RETURNS TRIGGER AS
$emp_trigger$
DECLARE id_series INTEGER;
DECLARE id_actor INTEGER;
BEGIN
  IF NOT EXISTS (SELECT actor_id FROM actor WHERE firstName = NEW.firstName AND lastName = NEW.lastName)
  THEN
    INSERT INTO actor (firstName, lastName, nationality)
     VALUES (NEW.firstName, NEW.lastName, NEW.nationality);
  END IF;

  IF NOT EXISTS (SELECT tv_series_id FROM tv_series WHERE title_series = NEW.title_series)
  THEN
    INSERT INTO tv_series (title_series, year, language, budget)
      VALUES (NEW.title_series, NEW.year, NEW.language, NEW.budget);
  END IF;

  id_series:= 0;
  id_actor:= 0;
  SELECT actor_id INTO id_actor FROM actor WHERE firstName = NEW.firstName AND lastName = NEW.lastName;
  SELECT tv_series_id INTO id_series FROM tv_series WHERE title_series = NEW.title_series;

  INSERT INTO starrIn (actor_id, tv_series_id)
    VALUES (id_actor, id_series);
  RETURN NEW;
END;
$emp_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER triggerActor
  BEFORE INSERT
  ON formActors_Series
FOR EACH ROW EXECUTE PROCEDURE actor_insertion();


------------------------------------------------------------------------------------------------------------------------


CREATE OR REPLACE FUNCTION award_insertion()
  RETURNS TRIGGER AS
$emp_trigger$
DECLARE id_series INTEGER;
DECLARE id_award INTEGER;
BEGIN
  IF NOT EXISTS (SELECT award_id FROM award WHERE category = NEW.category AND organize = NEW.organize)
  THEN
    INSERT INTO award (category, organize)
      VALUES (NEW.category, NEW.organize);
  END IF;

  IF NOT EXISTS (SELECT tv_series_id FROM tv_series WHERE title_series = NEW.title_series)
  THEN
    INSERT INTO tv_series (title_series, year, language, budget)
      VALUES (NEW.title_series, NEW.year, NEW.language, NEW.budget);
  END IF;

  id_series:= 0;
  id_award:= 0;
  SELECT award_id INTO id_award FROM award WHERE category = NEW.category AND organize = NEW.organize;
  SELECT tv_series_id INTO id_series FROM tv_series WHERE title_series = NEW.title_series;

  INSERT INTO awards_tvseries (award_id, tv_series_id)
    VALUES (id_award, id_series);
  RETURN NEW;
END;
$emp_trigger$ LANGUAGE plpgsql;

CREATE TRIGGER triggerAward
  BEFORE INSERT
  ON formAwards_Series
FOR EACH ROW EXECUTE PROCEDURE award_insertion();


------------------------------------------------------------------------------------------------------------------------


INSERT INTO formSeriesNetwork (title_series, year, language, budget, name_network, location)
    VALUES ('Suits', '2011', 'English', -1, 'USA Network', 'New York City');
INSERT INTO formSeriesNetwork VALUES ('Game of Thrones', '2011', 'English', 600000000, 'HBO', 'New York City');
INSERT INTO formSeriesNetwork VALUES ('Boardwalk Empire', '2010', 'English', 50000000, 'HBO', 'New York City');

INSERT INTO formActors_Series (firstName, lastName, nationality,title_series, year, language, budget)
    VALUES ('Gabriel', 'Macht', 'American','Suits', '2011', 'English', -1);
INSERT INTO formActors_Series VALUES  ('Patrick', 'Adams', 'American','Suits', '2011', 'English', -1);
INSERT INTO formActors_Series VALUES  ('Rick', 'Hoffman', 'American','Suits', '2011', 'English', -1);
INSERT INTO formActors_Series VALUES  ('Meghan' , 'Markle', 'American','Suits', '2011', 'English', -1);
INSERT INTO formActors_Series VALUES  ('Sarah', 'Rafferty', 'American','Suits', '2011', 'English', -1);

INSERT INTO formAwards_Series (category, organize, title_series, year, language, budget)
    VALUES ('Award for Outstanding Drama Series', 'Emmy Awards', 'Game of Thrones', '2011', 'English', 600000000);
INSERT INTO formAwards_Series VALUES ('Award for Outstanding Drama Series', 'Emmy Awards', 'Breaking Bad', '2008', 'English', 182000000);
INSERT INTO formAwards_Series VALUES ('Best Television Series – Drama', 'Golden Globe Awards', 'Boardwalk Empire', '2010', 'English', 50000000);


------------------------------------------------------------------------------------------------------------------------


SELECT * FROM tv_series;
SELECT * FROM network;
SELECT * FROM actor;
SELECT * FROM award;
SELECT * FROM featureIn;
SELECT * FROM starrIn;
SELECT * FROM awards_tvseries;