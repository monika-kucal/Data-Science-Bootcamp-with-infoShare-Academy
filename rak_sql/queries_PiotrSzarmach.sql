SELECT * FROM Wyniki;

--1) lista producentów z liczbą leków posortowana od największej ilości oferowanych leków
SELECT producent, COUNT(producent) as liczba_lekow
FROM Lek
GROUP BY producent
ORDER BY liczba_lekow;

--2) jakie leki o cenie powyżej 10zł produkowane przez polpharma nie mają wyników?
SELECT DISTINCT l.nazwa
FROM lek l
JOIN wyniki w ON l.id = w.id_leku
WHERE l.cena > 10.0 AND w.efekt = false AND l.producent = 'Polpharma';

--3) liczba leków w zależności od rodzaju, dawki i producenta
SELECT rodzaj, COUNT(id) over (PARTITION BY rodzaj),
  dawka, COUNT(id) over (PARTITION BY dawka),
  producent, COUNT(id) over (PARTITION BY producent)
FROM Lek;

--4) średnia cena leku w zależności od producenta i różnica z tej ceny w stosunku do
-- średniej ceny wszystkich leków
SELECT nazwa, AVG(cena) over (PARTITION BY producent) as srednia_producenta,
  AVG(cena) over (PARTITION BY producent) - (SELECT AVG(cena) FROM Lek) as roznica
FROM Lek;

--5) lista leków które mają więcej niż 10 wyników
SELECT l.nazwa, COUNT(w.id)
FROM Lek l
LEFT JOIN wyniki w ON l.id = w.id_leku
GROUP BY l.nazwa
HAVING COUNT(w.id) > 10;

--6) lista wyników w których MRI odbiega o minimum 10% od średniego wyniku całej grupy
SELECT w.*
FROM Wyniki w
WHERE w.MRI >= (SELECT AVG(MRI) FROM Wyniki) * 1.1
       OR w.MRI <= (SELECT AVG(MRI) FROM Wyniki) * 0.9;

--7) lista niekompletnych wyników gdzie któregoś wyniku brakuje
SELECT w.*
FROM Wyniki w
WHERE w.cisnienie = 0 OR w.ekg = null OR w.mri = 0 OR w.mocz = 0 OR w.tk = 0
  OR w.krew = 0 OR w.rtg = 0;

--8 ) średni czas od skierowania do badania
SELECT AVG(DATE_PART('day', w.databadania::timestamp - w.dataskierowania::timestamp))
FROM wyniki w;

--9) średni czas od skierowania do badania, od badania do oceny i od skierowania
-- do oceny w zależności od peselu lekarza
SELECT w.id_lekarza, AVG(DATE_PART('day', w.databadania::timestamp - w.dataskierowania::timestamp)) as oczekiwanie_badania,
  AVG(DATE_PART('day', w.dataoceny::timestamp - w.databadania::timestamp)) as oczekiwanie_ocena,
  AVG(DATE_PART('day', w.dataoceny::timestamp - w.dataskierowania::timestamp)) as oczekiwanie_proces
FROM Wyniki w
GROUP BY w.id_lekarza;

--10) lista lekarzy bardzo spowalniajacych proces leczenia
-- (średnia czasu od wykonania badań do oceny większa 50% niż mediana grupy)

CREATE FUNCTION _final_median(anyarray) RETURNS float8 AS $$
  WITH q AS
  (
     SELECT val
     FROM unnest($1) val
     WHERE VAL IS NOT NULL
     ORDER BY 1
  ),
  cnt AS
  (
    SELECT COUNT(*) AS c FROM q
  )
  SELECT AVG(val)::float8
  FROM
  (
    SELECT val FROM q
    LIMIT  2 - MOD((SELECT c FROM cnt), 2)
    OFFSET GREATEST(CEIL((SELECT c FROM cnt) / 2.0) - 1,0)
  ) q2;
$$ LANGUAGE SQL IMMUTABLE;

CREATE AGGREGATE median(anyelement) (
  SFUNC=array_append,
  STYPE=anyarray,
  FINALFUNC=_final_median,
  INITCOND='{}'
);

SELECT w.id_lekarza,
  AVG(DATE_PART('day', w.dataoceny::timestamp - w.databadania::timestamp)) as oczekiwanie,
  (SELECT median(DATE_PART('day', w.dataoceny::timestamp - w.databadania::timestamp)) FROM Wyniki w) as mediana
FROM Wyniki w
GROUP BY w.id_lekarza
HAVING AVG(DATE_PART('day', w.dataoceny::timestamp - w.databadania::timestamp))
       > 1.5 * (SELECT median(DATE_PART('day', w.dataoceny::timestamp - w.databadania::timestamp)) FROM Wyniki w);




