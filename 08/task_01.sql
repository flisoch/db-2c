CREATE TABLE "user" (
  id    SERIAL,
  name  VARCHAR(20),
  email VARCHAR(30),
  CONSTRAINT user_pk PRIMARY KEY (id)
);

CREATE TABLE user_log (
  id            SERIAL,
  old_user_name VARCHAR(20),
  new_user_name VARCHAR(20),
  old_email     VARCHAR(30),
  new_email     VARCHAR(30),
  date          TIMESTAMP,
  op_type       VARCHAR(6),
  CONSTRAINT user_log_pk PRIMARY KEY (id)
);

CREATE FUNCTION log_user_insert()
  RETURNS TRIGGER AS $log_user_insert$
BEGIN
  INSERT INTO user_log (new_user_name, new_email, date, op_type) VALUES (NEW.name, NEW.email, now(), TG_OP);
  RETURN NEW;
END;
$log_user_insert$
LANGUAGE plpgsql;

CREATE FUNCTION log_user_update()
  RETURNS TRIGGER AS $log_user_update$
BEGIN
  INSERT INTO user_log (old_user_name, new_user_name, old_email, new_email, date, op_type)
  VALUES (OLD.name, NEW.name, OLD.email, NEW.email, now(), TG_OP);
  RETURN NEW;
end;
$log_user_update$
LANGUAGE plpgsql;

CREATE FUNCTION log_user_delete()
  RETURNS TRIGGER AS $log_user_delete$
BEGIN
  INSERT INTO user_log (old_user_name, old_email, date, op_type) VALUES (OLD.name, OLD.email, now(), TG_OP);
  RETURN OLD;
end;
$log_user_delete$
LANGUAGE plpgsql;

CREATE TRIGGER log_user_insert
  AFTER INSERT
  ON "user"
  FOR EACH ROW EXECUTE PROCEDURE log_user_insert();

CREATE TRIGGER log_user_delete
  AFTER DELETE
  ON "user"
  FOR EACH ROW EXECUTE PROCEDURE log_user_delete();

CREATE TRIGGER log_user_update
  AFTER UPDATE
  ON "user"
  FOR EACH ROW EXECUTE PROCEDURE log_user_update();


INSERT INTO "user" (name, email)
VALUES ('vasya', 'vasya@mail.ru');

UPDATE "user"
SET name  = 'tolya',
    email = 'tolya@mail.ru'
WHERE name = 'vasya';

DELETE
FROM "user"
WHERE name = 'tolya';
