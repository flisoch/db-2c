
CREATE TABLE product(
  id SERIAL,
  name VARCHAR(20),
  price INTEGER,
  CONSTRAINT product_pk PRIMARY KEY (id)
);

CREATE TABLE sale(
  id SERIAL,
  product_id INTEGER,
  new_price INTEGER,
  date TIMESTAMP,
  CONSTRAINT sale_pk PRIMARY KEY (id),
  CONSTRAINT product_fk FOREIGN KEY (product_id) REFERENCES product(id)
);


CREATE FUNCTION check_new_price()
  RETURNS TRIGGER AS $check_new_price$
DECLARE
  old_price INTEGER;
  new_price INTEGER;
BEGIN
  SELECT price INTO old_price FROM product WHERE id = NEW.product_id;
  new_price = NEW.new_price;
  IF (old_price < new_price) THEN
    RAISE EXCEPTION 'New price must be lower than old!';
  END IF;
  RETURN NEW;
END;
$check_new_price$ LANGUAGE plpgsql;

CREATE TRIGGER check_new_price
  BEFORE INSERT OR UPDATE
  ON sale
  FOR EACH ROW EXECUTE PROCEDURE check_new_price();


INSERT INTO product (name, price) VALUES ('beef', 400);
INSERT INTO sale (product_id, new_price, date) VALUES (1,360, now());


INSERT INTO product (name, price) VALUES ('pork', 300);
INSERT INTO sale (product_id, new_price, date) VALUES (2, 320, now());
