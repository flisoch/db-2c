CREATE OR REPLACE FUNCTION periodAverageTemperature(year1 INTEGER, year2 INTEGER, OUT avg_temp DOUBLE PRECISION)
AS $$
DECLARE
  sum_of_avg_temps DOUBLE PRECISION = 0;
  cur_avg_temp     DOUBLE PRECISION = 0;
BEGIN
  FOR year IN year1..year2 LOOP
    SELECT averagetemperature(year) INTO cur_avg_temp;
    sum_of_avg_temps := sum_of_avg_temps + cur_avg_temp;
  end loop;
  avg_temp := sum_of_avg_temps / (year2 - year1 + 1);
end;
$$
LANGUAGE plpgsql;

SELECT averagetemperature(1983);
SELECT periodAverageTemperature(1983, 1984);
