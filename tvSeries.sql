CREATE TABLE series (
  series_id SMALLINT    NOT NULL DEFAULT 0,
  title        VARCHAR(45) NOT NULL,
  year         INT         NOT NULL,
  language     VARCHAR(30) NOT NULL,
  budget       INT         NOT NULL,
  PRIMARY KEY  (series_id)
);

CREATE TABLE actor (
  actor_id    SMALLINT    NOT NULL DEFAULT 0,
  first_name  VARCHAR(45) NOT NULL,
  last_name   VARCHAR(45) NOT NULL,
  nationality VARCHAR(45) NOT NULL,
  PRIMARY KEY  (actor_id)
);

CREATE TABLE network (
  network_id SMALLINT    NOT NULL DEFAULT 0,
  name       VARCHAR(45) NOT NULL,
  location   VARCHAR(45) NOT NULL,
  PRIMARY KEY  (network_id)
);

CREATE TABLE award (
  award_id    SMALLINT    NOT NULL DEFAULT 0,
  category    VARCHAR(45) NOT NULL,
  organizer   VARCHAR(45) NOT NULL,
  PRIMARY KEY  (award_id)
);

CREATE TABLE starsIn (
  actor_id  SMALLINT NOT NULL DEFAULT 0,
  series_id SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (actor_id, series_id),
  FOREIGN KEY (actor_id)  REFERENCES actor (actor_id),
  FOREIGN KEY (series_id) REFERENCES series (series_id)
);

CREATE TABLE belongsTo (
  network_id  SMALLINT NOT NULL DEFAULT 0,
  series_id   SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (network_id, series_id),
  FOREIGN KEY (network_id)  REFERENCES network (network_id),
  FOREIGN KEY (series_id)   REFERENCES series (series_id)
);

CREATE TABLE actorWins (
  actor_id  SMALLINT NOT NULL DEFAULT 0,
  award_id  SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (actor_id, award_id),
  FOREIGN KEY (actor_id)  REFERENCES actor (actor_id),
  FOREIGN KEY (award_id) REFERENCES award (award_id)
);

CREATE TABLE seriesWin (
  series_id  SMALLINT NOT NULL DEFAULT 0,
  award_id   SMALLINT NOT NULL DEFAULT 0,
  PRIMARY KEY (series_id, award_id),
  FOREIGN KEY (series_id)  REFERENCES series (series_id),
  FOREIGN KEY (award_id)   REFERENCES award (award_id)
);

-- Showing tables
SELECT * FROM pg_catalog.pg_tables
WHERE schemaname != 'pg_catalog' AND schemaname != 'information_schema';