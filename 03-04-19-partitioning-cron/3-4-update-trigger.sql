CREATE OR REPLACE FUNCTION update_partition()
  RETURNS TRIGGER AS $update_partition$
DECLARE   old_year INTEGER;
  DECLARE new_year INTEGER;
BEGIN
  SELECT EXTRACT(YEAR FROM new.date) INTO new_year;
  SELECT EXTRACT(YEAR FROM old.date) INTO old_year;

  IF new_year <> old_year
  THEN
    -- create new partition table and update trigger if Table doesn't exist
    IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname = 'workout_stats_'||new_year)
    THEN
      EXECUTE format(
          'CREATE TABLE IF NOT EXISTS workout_stats_%s (CONSTRAINT workout_stats_%s_pk PRIMARY KEY(id)) INHERITS(workout_stats)',
          new_year, new_year);
      EXECUTE format('CREATE TRIGGER update_data
      BEFORE UPDATE
      ON workout_stats_%s
      FOR EACH ROW EXECUTE PROCEDURE update_partition();', new_year);
    END IF;
    --if years differ, insert new data into another partition and delete record from old partition
    EXECUTE format('INSERT INTO workout_stats_%s(date, push_ups, pull_ups, squats) VALUES($1,$2,$3,$4)', new_year)
    using
      new.date, new.push_ups, new.pull_ups, new.squats;
    EXECUTE format('DELETE FROM workout_stats_%s WHERE date=$1 AND push_ups=$2 AND pull_ups=$3 AND squats=$4', old_year)
    using
      old.date, old.push_ups, old.pull_ups, old.squats;
    RETURN null;
  END IF;
  return new;
end;
$update_partition$
LANGUAGE plpgsql;

CREATE TRIGGER update_data
  BEFORE UPDATE
  ON workout_stats
  FOR EACH ROW EXECUTE PROCEDURE update_partition();


INSERT into workout_stats (date, push_ups, pull_ups, squats)
VALUES ('2019-03-06 00:10:25-07', 100, 0, 0);

SELECT * FROM workout_stats;
SELECT * FROM workout_stats_2019;
SELECT * FROM workout_stats_2020;

UPDATE workout_stats SET date = '2020-03-06 00:10:25' WHERE date = '2019-03-06 00:10:25';
UPDATE workout_stats SET date = '2019-03-03 00:10:25' WHERE date = '2020-03-03 00:10:25';
