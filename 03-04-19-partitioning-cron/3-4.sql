CREATE TABLE workout_stats (
  id       SERIAL,
  date     TIMESTAMP,
  push_ups INTEGER DEFAULT 0,
  pull_ups INTEGER DEFAULT 0,
  squats   INTEGER DEFAULT 0
);


CREATE OR REPLACE FUNCTION insert_partition()
  RETURNS TRIGGER AS $insert_partition$
DECLARE year INTEGER;
BEGIN
  SELECT EXTRACT(YEAR FROM new.date) INTO year;
  EXECUTE format(
      'CREATE TABLE IF NOT EXISTS workout_stats_%s (CONSTRAINT workout_stats_%s_pk PRIMARY KEY(id)) INHERITS(workout_stats)',
      year, year);
  RAISE NOTICE 'date: %', new.date;
  EXECUTE format('INSERT INTO workout_stats_%s(date, push_ups, pull_ups, squats) VALUES($1,$2,$3,$4)', year)
  using
    new.date, new.push_ups, new.pull_ups, new.squats;
  RETURN null;
end;
$insert_partition$
LANGUAGE plpgsql;

CREATE TRIGGER insert_data
  BEFORE INSERT
  ON workout_stats
  FOR EACH ROW EXECUTE PROCEDURE insert_partition();


INSERT into workout_stats (date, push_ups, pull_ups, squats)
VALUES ('2019-03-01 00:10:25-07', 100, 0, 0);
SELECT * FROM workout_stats;
SELECT * FROM ONLY workout_stats;
