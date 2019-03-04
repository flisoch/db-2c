CREATE TABLE weather (
  day          INTEGER,
  average_temp DOUBLE PRECISION
);

CREATE TABLE weather_1983 (
  CHECK (day > 0 AND day <= 365)
)
  INHERITS (weather);

CREATE TABLE weather_1984 (
  CHECK (day > 0 AND day <= 365)
)
  INHERITS (weather);


CREATE OR REPLACE FUNCTION averageTemperature(year INTEGER)
  RETURNS DOUBLE PRECISION AS $$
DECLARE avg_temp DOUBLE PRECISION;
BEGIN
  EXECUTE format('SELECT avg(average_temp) FROM weather_%s ', year)
  INTO avg_temp;
  RETURN avg_temp;
end;
$$
LANGUAGE plpgsql;

INSERT INTO weather_1983 (day, average_temp)
VALUES (1, 22.4),
       (2, 17.6);
INSERT INTO weather_1984 (day, average_temp)
VALUES (1, 12.4),
       (2, 7.6);

SELECT averageTemperature(1983);
SELECT averageTemperature(1984);


