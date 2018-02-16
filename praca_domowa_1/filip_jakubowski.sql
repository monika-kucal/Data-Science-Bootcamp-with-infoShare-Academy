-- 1. Z którego kraju mamy najwięcej wniosków?
SELECT kod_kraju, count(1)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC;

-- 2. Z którego języka mamy najwięcej wniosków?
SELECT jezyk, count(1)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC;

--3 Ile % procent klientów podróżowało w celach biznesowych a ilu w celach prywatnych?
--Jezeli chcemy, aby uwzglednial tylko biznesowe i prywatne usuwamy "--" wtedy wyeliminuje nam NULL i zliczy tylko dostepne

SELECT typ_podrozy, count(1) as suma_typow_podrozy,
   round(count(1)/sum(count(1)) over()::NUMERIC,4) procent_podrozy
  FROM wnioski
  --WHERE typ_podrozy is NOT NULL
  GROUP BY 1

UNION
  SELECT 'suma', count(1), count(1)/sum(count(1)) over()::NUMERIC
  FROM wnioski
  --WHERE typ_podrozy is NOT NULL
  ORDER BY 1 ;

-- 4 Jak procentowo rozkładają się źródła polecenia?
SELECT zrodlo_polecenia, count(1) as suma_zrodel_polecenia,
  round(count(1)/sum(count(1)) over()::NUMERIC,4) procent_polecanych
  FROM wnioski w
  WHERE w.zrodlo_polecenia is NOT NULL
  GROUP BY 1

UNION
  SELECT 'Suma', count(1), count(1)/sum(count(1)) over()::NUMERIC
  FROM wnioski w
  WHERE w.zrodlo_polecenia is NOT NULL
  ORDER BY 1 DESC ;

-- 5 Ile podróży to trasy złożone z jednego / dwóch / trzech / więcej tras?

WITH trasa_laczona AS (
  SELECT id_podrozy, COUNT(1) AS ilosc_tras
   FROM szczegoly_podrozy
   GROUP BY 1 )
SELECT
 CASE
   WHEN ilosc_tras > 3 THEN '3+'
   WHEN ilosc_tras = 3 THEN '3'
   WHEN ilosc_tras = 2 THEN '2'
   WHEN ilosc_tras = 1 THEN '1'
 END as ilosc_przesiadek,
 COUNT(1) suma_ilosc_tras
FROM trasa_laczona
GROUP BY 1
ORDER BY 1;

-- 6 Na które konto otrzymaliśmy najwięcej / najmniej rekompensaty?

SELECT konto, count(1) liczba_rekompensat, sum(kwota) suma_rekompensat,
      min(kwota) min_kwota_rekompensat,
      max(kwota) max_kwota_rekompensat
FROM szczegoly_rekompensat
GROUP BY konto
ORDER BY 1;

-- 7 Który dzień jest rekordowym w firmie w kwestii utworzonych wniosków?

SELECT to_char(data_utworzenia, 'YYYY-MM-DD') AS data_utw, count(1) ilosc_rekompensat
FROM szczegoly_rekompensat
GROUP BY 1
ORDER BY 2 DESC;

-- 8 Który dzień jest rekordowym w firmie w kwestii otrzymanych rekompensat?

SELECT to_char(data_otrzymania, 'YYYY-MM-DD') AS data_otrz, count(1) ilosc_rekompensat, sum(kwota) suma_rekompensat
FROM szczegoly_rekompensat
GROUP BY 1
-- jezelimamy okreslic data w ktorej bylo najwiecej wnioskow wtedy order by 2, jezeli mamy okreslicdate w ktorej s
-- umarycznie otrzymalismy najwiecej sumarycznej wartosi rekompensat wtedy order by 3
ORDER BY 2 DESC

-- 9 Jaka jest dystrubucja tygodniowa wniosków według kanałów? (liczba wniosków w danym tygodniu w każdym kanale)

SELECT to_char(data_utworzenia, 'YYYY-WW') data_utworzenia ,kanal, count(1) as suma_zrodel_polecenia,
  round(count(1)/sum(count(1)) over()::NUMERIC,5) procent_polecanych
  FROM wnioski w
  WHERE w.zrodlo_polecenia is NOT NULL
  GROUP BY 1, 2
  ORDER BY 1