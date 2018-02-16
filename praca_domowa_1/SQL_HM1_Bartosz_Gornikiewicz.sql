-- Z ktoreg kraju mamy najwiecej wnioskow?
SELECT kod_kraju, COUNT(1)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Z jakiego jezyka mamy najwiecej wnioskow?
SELECT jezyk, COUNT(1)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Ile procent podroznych podrozowalo w celach biznesowych a ilu prywatnych?
SELECT
  typ_podrozy,
  SUM(liczba_pasazerow)/SUM(SUM(liczba_pasazerow)) OVER()::NUMERIC AS prc
FROM wnioski
WHERE typ_podrozy IS NOT NULL
GROUP BY 1;

-- Jak procentowo rozkladaja sie zrodla polecenia
SELECT
  kanal,
  COUNT(1)/SUM(COUNT(1)) OVER ()::NUMERIC AS prc
FROM wnioski
GROUP BY 1;


-- Ile podrozy to trasy zlozone?
WITH odcinki AS (
    SELECT id_podrozy, COUNT(1) AS n
    FROM szczegoly_podrozy
    GROUP BY 1
)
SELECT
  CASE
    WHEN n > 3 THEN '3+'
    WHEN n = 3 THEN '3'
    WHEN n = 2 THEN '2'
    WHEN n = 1 THEN '1'
  END,
  COUNT(1)
FROM odcinki
GROUP BY 1
ORDER BY 1;

-- Na ktore konto otrzymalismy najwiecej/najmniej rekompensat?;

-- NAJMIEJ

SELECT
  konto,
  SUM(kwota) AS suma
FROM szczegoly_rekompensat
GROUP BY 1
ORDER BY 2
LIMIT 1;

--NAJWIĘCEJ

SELECT
  konto,
  SUM(kwota) AS suma
FROM szczegoly_rekompensat
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Ktory dzien jest rekordowy w firmie pod wzgledem utworzonych wnioskow?

SELECT
  TO_CHAR(data_utworzenia, 'YYYY-MM-DD') AS data_utw,
  COUNT(1)
FROM wnioski
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Ktory dzien jest rekordowy w firmie pod wzgledem otrzymanych rekompensat?

SELECT
  TO_CHAR(data_otrzymania, 'YYYY-MM-DD') AS data_otrz,
  COUNT(1)
FROM szczegoly_rekompensat
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- Jaka jest dystrubucja tygodniowa wniosków według kanałów?
SELECT
  TO_CHAR(data_utworzenia, 'WW'),
  kanal,
  COUNT(1)
FROM wnioski
WHERE kanal IS NOT NULL
GROUP BY 1, 2;

-- Lista wniosków przeterminowanych (przeterminowany = utworzony w naszej firmie powyżej 3 lat od daty podróży)
SELECT
  w.id,
  TO_CHAR(w.data_utworzenia, 'YYYY-MM-DD') AS data_utw,
  s.data_wyjazdu
FROM wnioski w
LEFT JOIN podroze p ON w.id = p.id_wniosku
LEFT JOIN szczegoly_podrozy s ON p.id = s.id_podrozy
WHERE w.data_utworzenia > s.data_wyjazdu  + INTERVAL '3 years';

-- Firmie zależy na tym, aby klienci do nas wracali.
-- Jaka część naszych klientów to powracające osoby?
WITH kli_wni AS (
  SELECT
    k.id,
    COUNT(w.id) AS n_wni
  FROM klienci k
  LEFT JOIN wnioski w ON k.id_wniosku = w.id
  GROUP BY k.id)
SELECT
  COUNT(CASE WHEN n_wni > 1 THEN kli_wni.id END)/COUNT(kli_wni.id)::NUMERIC AS prc_powr
FROM kli_wni;

-- Jaka część naszych współpasażerów to osoby, które już wcześniej pojawiły się na jakimś wniosku?
WITH wsp_wni AS (
  SELECT
    w.id,
    COUNT(w2.id) AS n_wni
  FROM wspolpasazerowie w
  LEFT JOIN wnioski w2 ON w.id_wniosku = w2.id
  GROUP BY 1)
SELECT
  COUNT(CASE WHEN n_wni >1 THEN wsp_wni.id END)/COUNT(wsp_wni.id)::NUMERIC AS prc_wcz
FROM wsp_wni;

-- Jaka część klientów pojawiła się na innych wnioskach jako współpasażer?



-- Czy jako nowy klient mający kilka zakłóceń, od razu składasz kilka wniosków? Jaki jest czas od złożenia pierwszego do kolejnego wniosku?
