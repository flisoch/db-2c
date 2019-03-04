create table emp (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(32)                NOT NULL,
  office_id INT REFERENCES office (id) NOT NULL

);
CREATE TABLE office (
  id        SERIAL PRIMARY KEY,
  name      VARCHAR(32) NOT NULL,
  emp_count INT         NOT NULL,
  CONSTRAINT count_must_be_zero_or_greater CHECK (emp_count >= 0)
);

CREATE OR REPLACE FUNCTION new_emp_office_update_count()
  RETURNS TRIGGER AS $new_emp_office_update_count$
BEGIN
  UPDATE office SET emp_count = emp_count + 1 WHERE id = NEW.office_id;

  RETURN NEW;
end;
$new_emp_office_update_count$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION move_emp_office_update_count()
  RETURNS TRIGGER AS $move_emp_office_update_count$
BEGIN
  UPDATE office SET emp_count = emp_count - 1 WHERE id = OLD.office_id;
  UPDATE office SET emp_count = emp_count + 1 WHERE id = NEW.office_id;
  RETURN NEW;
end;
$move_emp_office_update_count$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION fire_emp_office_update_count()
  RETURNS TRIGGER AS $fire_emp_office_update_count$
BEGIN
  UPDATE office SET emp_count = emp_count - 1 WHERE id = OLD.office_id;
  RETURN NULL;
end;
$fire_emp_office_update_count$
LANGUAGE plpgsql;


CREATE TRIGGER new_emp_office_update_count
  AFTER INSERT
  ON emp
  FOR EACH ROW EXECUTE PROCEDURE new_emp_office_update_count();

CREATE TRIGGER move_emp_office_update_count
  AFTER UPDATE ON emp
  FOR EACH ROW EXECUTE PROCEDURE move_emp_office_update_count();

CREATE TRIGGER fire_emp_office_update_count
  AFTER DELETE ON emp
  FOR EACH ROW EXECUTE PROCEDURE fire_emp_office_update_count();


SELECT * from office;
SELECT * from emp;
INSERT INTO office(name) VALUES ('office 1'),('office 2');
INSERT INTO emp(name, office_id) VALUES ('zina', 2),('dima',3);
UPDATE emp SET office_id = 3 WHERE name = 'zina';
DELETE FROM emp WHERE name = 'zina';