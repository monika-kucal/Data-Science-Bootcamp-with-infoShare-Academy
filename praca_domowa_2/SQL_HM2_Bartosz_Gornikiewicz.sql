-- OBOWIAZKOWE:

-- 1. Jaka data była 8 dni temu?

-- "Dzisiaj" traktujemy jako dzień 1, a nie dzień 0 dlatego odejmujemy tylko 7 dni.
SELECT (NOW() - INTERVAL '7 days')::date;

-- 2. Jaki dzień tygodnia był 3 miesiące temu?

-- Jak wyżej, dlatego trzeba dodać jeden dziń.
SELECT (NOW() - INTERVAL '3 months' + INTERVAL '1 day')::date;

-- 3. W którym tygodniu roku jest 01 stycznia 2017?

SELECT TO_CHAR('2017-01-01':: date, 'WW');

--  4. Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę).

-- Jakie mamy kombinacje powodów operatora i typów wniosków?
SELECT DISTINCT powod_operatora, typ_wniosku
FROM wnioski;

-- Z zapytania powyżej wiemy, że jesteśmy zainteresowani wnioskami o typie "anulowany".
SELECT
  w.id,
  s.identyfikator_operatora,
  s.identyfikator_operator_operujacego,
  s.data_wyjazdu
FROM wnioski w
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s ON s.id_podrozy = p.id
-- wybieramy podróże 'anulowane'
WHERE w.typ_wniosku = 'anulowany';

-- 5. Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku. 3 kolumny: email, data 1wszego wniosku, data 2giego wniosku

WITH klient_daty AS (
  SELECT
    -- wybieramy emaile i daty utworzenia
    k.email email,
    w.data_utworzenia data_utw,
    -- nadajemy ranking utworzenia wniosku stosując okno na email i sortując po dacie utworzenia
    RANK() OVER (PARTITION BY email ORDER BY w.data_utworzenia) ranking
  FROM klienci k
  JOIN wnioski w ON k.id_wniosku = w.id
  GROUP BY 1, 2
  ORDER BY 1),
wniosek_1 AS (
  -- wybieramy pierwze wnioski
      SELECT
    email email_1,
    data_utw data_utw_1
  FROM klient_daty
  WHERE ranking = 1
  ),
wniosek_2 AS (
SELECT
  -- wybieramy drugie wnioski
  email email_2,
  data_utw data_utw_2
FROM klient_daty
WHERE ranking = 2)

SELECT
  email_1,
  data_utw_1,
  data_utw_2
FROM wniosek_1
-- Możemy użyć LEFT JOIN, ale więszość klientów złożyła tylko jeden wniosek
-- LEFT JOIN wniosek_2 ON wniosek_2.email_2 = wniosek_1.email_1;
-- lepszy jest JOIN, bo wtedy paruje tylko emaile, które występują zarównow wniosek_1 i wniosek_2
JOIN wniosek_2 ON wniosek_2.email_2 = wniosek_1.email_1;

-- 6. Używając pełen kod do predykcji wniosków,
-- zmień go tak aby uwzględnić kampanię marketingową,
-- która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000

-- Zakładam, że 26 lutego złożone będzie 1000 wniosków w wyniku uruchomienia kampanii
-- Dla czytelności usunąłem komentarze z zajęc, więc zostają tylko komentarze do rozwiązania zadania
with moje_daty as (select
  generate_series(
      date_trunc('day', '2018-01-20'::date),
      date_trunc('month', now())+interval '1 month'-interval '1 day',
      '1 day')::date as wygenerowana_data
  ),

  aktualne_wnioski as (
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),

  lista_z_wnioskami as (
    select md.wygenerowana_data,
      coalesce(aw.liczba_wnioskow,0) liczba_wnioskow,
      sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow
    from moje_daty md
    left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data
    order by 1),

  statystyki_dnia as (
    select
    to_char(wygenerowana_data, 'Day') dzien,
    round(avg(liczba_wnioskow)) przew_liczba_wnioskow
    from lista_z_wnioskami
    where wygenerowana_data <= '2018-02-09'
    group by 1
    order by 1),

-- Dodanie daty kampanii i szacowanej liczby wniosków, które ona wygeneruje
  kampania AS (
    SELECT '2018-02-26'::date AS dat_kam, 1000 AS n_wnioskow
  )

SELECT
  lw.wygenerowana_data,
  liczba_wnioskow,
  przew_liczba_wnioskow,
  -- dodajemy kolumne wniosków pochodzących z kampanii
  coalesce(kam.n_wnioskow, 0) wnioski_z_kampanii,
  CASE
    WHEN wygenerowana_data <= '2018-02-09' then liczba_wnioskow
  -- modyfikujemy finalną liczbę wniosków
  -- dodaje coalesce aby możliwe były obliczenia
  ELSE przew_liczba_wnioskow + coalesce(kam.n_wnioskow, 0)
  END finalna_liczba_wnioskow,
  SUM(CASE
    WHEN wygenerowana_data <= '2018-02-09' then liczba_wnioskow
  -- modyfikujemy skumulowaną predykcje
  -- dodaje coalesce aby możliwe były obliczenia
    ELSE przew_liczba_wnioskow + coalesce(kam.n_wnioskow, 0)
  END) OVER (ORDER BY wygenerowana_data) skumulowana_z_predykcja
FROM lista_z_wnioskami lw
JOIN statystyki_dnia sd ON sd.dzien = to_char(lw.wygenerowana_data, 'Day')
-- Dołączamy tabelę kampania
LEFT JOIN kampania kam ON kam.dat_kam = lw.wygenerowana_data;

-- 7. Używając pełen kod do predykcji wniosków,
-- zmień go tak aby uwzględnić przymusową przerwę serwisową,
-- w sobotę 24 lutego nie będzie można utworzyć żadnych wniosków

-- wykorzystuję już zmodyfikowany kod z zadania 6

with moje_daty as (select
  generate_series(
      date_trunc('day', '2018-01-20'::date),
      date_trunc('month', now())+interval '1 month'-interval '1 day',
      '1 day')::date as wygenerowana_data
  ),

  aktualne_wnioski as (
    select to_char(data_utworzenia, 'YYYY-MM-DD')::date data_wniosku, count(1) liczba_wnioskow
    from wnioski
    group by 1
  ),

  lista_z_wnioskami as (
    select md.wygenerowana_data,
      coalesce(aw.liczba_wnioskow,0) liczba_wnioskow,
      sum(aw.liczba_wnioskow) over(order by md.wygenerowana_data) skumulowana_liczba_wnioskow
    from moje_daty md
    left join aktualne_wnioski aw on aw.data_wniosku = md.wygenerowana_data
    order by 1),

  statystyki_dnia as (
    select
    to_char(wygenerowana_data, 'Day') dzien,
    round(avg(liczba_wnioskow)) przew_liczba_wnioskow
    from lista_z_wnioskami
    where wygenerowana_data <= '2018-02-09'
    group by 1
    order by 1),

-- Dodanie daty kampanii i szacowanej liczby wniosków, które ona wygeneruje,
-- w ten sposób mogę dopisać wiele kampanii (???)
  kampania AS (
    SELECT '2018-02-26'::date AS dat_kam, 1000 AS n_wni_kam
  ),

-- Dodaje pracę serwisową
-- w ten sposób mogę dopisać wiele prac serwisowych (???)
  serwis AS (
    SELECT '2018-02-24'::date dat_ser, 0 AS n_wni_ser
  )

SELECT
  lw.wygenerowana_data,
  liczba_wnioskow,
  przew_liczba_wnioskow,
  -- dodaję kolumnę z liczbą wniosków podczas prac serwisowych,
  -- zostawiam nulle, bo będą przydatne
  ser.n_wni_ser,
  -- dodaję kolumne wniosków pochodzących z kampanii
  kam.n_wni_kam wnioski_z_kampanii,
  CASE
    WHEN wygenerowana_data <= '2018-02-09' then liczba_wnioskow
  -- modyfikujemy finalną liczbę wniosków
  -- dodaje coalesce aby możliwe były obliczenia
  -- dodaje uwzglednienei prac serwisowych
    ELSE coalesce(ser.n_wni_ser, przew_liczba_wnioskow + coalesce(kam.n_wni_kam, 0))
  END finalna_liczba_wnioskow,
  SUM(CASE
    WHEN wygenerowana_data <= '2018-02-09' then liczba_wnioskow
  -- modyfikujemy skumulowaną predykcje
  -- dodaje coalesce aby możliwe były obliczenia
  -- dodaje uwzglednienei prac serwisowych
    ELSE coalesce(ser.n_wni_ser, przew_liczba_wnioskow + coalesce(kam.n_wni_kam, 0))
  END) OVER (ORDER BY wygenerowana_data) skumulowana_z_predykcja
FROM lista_z_wnioskami lw
JOIN statystyki_dnia sd ON sd.dzien = to_char(lw.wygenerowana_data, 'Day')
-- Dołączamy tabelę kampania
LEFT JOIN kampania kam ON kam.dat_kam = lw.wygenerowana_data
-- Dołączam tabelę serwis
LEFT JOIN serwis ser ON ser.dat_ser = lw.wygenerowana_data;

-- 8. Ile (liczbowo) wniosków zostało utworzonych poniżej mediany liczonej z czasu między lotem i wnioskiem?

WITH
-- obliczam różnicę między datą utworzenia wniosku i datą wyjazdu
roznica AS (
  SELECT
    w.data_utworzenia - s.data_wyjazdu roznica
  FROM wnioski w
  JOIN podroze p ON w.id = p.id_wniosku
  JOIN szczegoly_podrozy s ON p.id = s.id_podrozy
  ),
-- obliczam medianę
mediana AS (
  SELECT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY roznica) mediana
  FROM roznica
  )
-- zliczam rekordy w których różnica jest mniejsza niz mediana
SELECT
  COUNT(1)
FROM roznica
WHERE roznica < (SELECT * FROM mediana);

-- 9. Mając czas od utworzenia wniosku do jego analizy przygotuj statystyke:

/*
jaka jest mediana czasu?
jaka jest srednia czasu?
jakie mamy wartości odstające?
ile jest wnioskow ponizej p75?
ile jest wnioskow powyzej p25?
czy te dane znacząco roznią się jesli rozbijemy je na zaakceptowane i odrzucone?
 */

-- wyciągam potrzebne dane i obliczam czas przetwarzania wniosku
WITH czas_przetwarzania AS (
  SELECT
    w.data_utworzenia data_utw,
    -- biorę datę zakończenia z tabeli analizy wniosków jako końcową datę pracy na wniosku
    a.data_zakonczenia data_anal,
    a.data_zakonczenia - w.data_utworzenia czas,
    a.status status
  FROM wnioski w
  -- stosując ten join zostają nam tylko przeanalizowane wnioski
  JOIN analizy_wnioskow a ON w.id = a.id_wniosku
  -- usuwam błędne rekordy, czyli takie ktore są zakończone przed złożeniem wniosku
  WHERE a.data_zakonczenia >= w.data_utworzenia
),

-- obliczny kwartyle dla wszystkich
kwartyle_wszystkie AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY czas) Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) Q2,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY czas) Q3
  FROM czas_przetwarzania
),

-- obliczny statystyki dla wszystkich
statystyki_wszystkie AS (
  SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) mediana,
    AVG(czas) srednia,
    -- wartości odstające powyżej 1.5x rozstepu ćwiartkowego,
    -- poniewaz jest on kilkudniowy to mozemy miec tylko zadługi czas analizy wnioskow,
    -- czyli granica to q3+1.5x(q3-q1)
    (SELECT q3+1.5*(q3-q1) FROM kwartyle_wszystkie) granica,
    COUNT(CASE WHEN czas < q1 THEN 1 END) ponizej_q1,
    COUNT(CASE WHEN czas > q3 THEN 1 END) powyzej_q3,
    COUNT(CASE WHEN czas > q3+1.5*(q3-q1) THEN 1 END) poza_gran
  FROM czas_przetwarzania
  JOIN kwartyle_wszystkie ON 1=1),

-- robimy to samo, ale tylko dla odrzuconych, dodajemy klauzule WHERE
kwartyle_odrzucone AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY czas) Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) Q2,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY czas) Q3
  FROM czas_przetwarzania
  WHERE status = 'odrzucony'
),

statystyki_odrzucone AS (
  SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) mediana,
    AVG(czas) srednia,
    -- wartości odstające powyżej 1.5x rozstepu ćwiartkowego,
    -- poniewaz jest on kilkudniowy to mozemy miec tylko zadługi czas analizy wnioskow,
    -- czyli granica to q3+1.5x(q3-q1)
    (SELECT q3+1.5*(q3-q1) FROM kwartyle_odrzucone) granica,
    COUNT(CASE WHEN czas < q1 THEN 1 END) ponizej_q1,
    COUNT(CASE WHEN czas > q3 THEN 1 END) powyzej_q3,
    COUNT(CASE WHEN czas > q3+1.5*(q3-q1) THEN 1 END) poza_gran
  FROM czas_przetwarzania
  JOIN kwartyle_odrzucone ON 1=1
  WHERE status = 'odrzucony'),

-- robimy to samo dla zaakceptowanych, dodajemy klauzule WHERE
kwartyle_zaakceptowany AS (
  SELECT
    PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY czas) Q1,
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) Q2,
    PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY czas) Q3
  FROM czas_przetwarzania
  WHERE status = 'zaakceptowany'
),

statystyki_zaakceptowany AS (
  SELECT
    PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY czas) mediana,
    AVG(czas) srednia,
    -- wartości odstające powyżej 1.5x rozstepu ćwiartkowego,
    -- poniewaz jest on kilkudniowy to mozemy miec tylko zadługi czas analizy wnioskow,
    -- czyli granica to q3+1.5x(q3-q1)
    (SELECT q3+1.5*(q3-q1) FROM kwartyle_zaakceptowany) granica,
    COUNT(CASE WHEN czas < q1 THEN 1 END) ponizej_q1,
    COUNT(CASE WHEN czas > q3 THEN 1 END) powyzej_q3,
    COUNT(CASE WHEN czas > q3+1.5*(q3-q1) THEN 1 END) poza_gran
  FROM czas_przetwarzania
  JOIN kwartyle_zaakceptowany ON 1=1
  WHERE status = 'zaakceptowany')


-- połączenie wszystkich statystyk
SELECT 'wszystkie' AS typ, *
FROM statystyki_wszystkie
UNION
SELECT 'odrzucone' AS typ, *
FROM statystyki_odrzucone
UNION
SELECT 'zaakceptowane' AS typ, *
FROM statystyki_zaakceptowany;

-- Czas nie różni się znacząc w poszczegolnych podgrupach.
-- Różnica w medianie między wszystkimi, odrzuconymi i zaakceptowanymi wnioskami jest mniejsza niż 2 godziny.
-- Średnio wniosek zaakceptowany jest przetwarzany 4 dni czybciej.

-- 10. Chcę bardziej spersonalizować naszą stronę internetową pod wymagania klientów.
-- Aby to zrobić potrzebuję analizy dotyczącej języków używanych przez klientów:
-- Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)

SELECT
  w.jezyk,
  COUNT(DISTINCT k.email) liczba_klientow,
  COUNT(DISTINCT k.email)/SUM(COUNT(DISTINCT k.email)) OVER()::NUMERIC prc_klientow
FROM wnioski w
JOIN klienci k ON w.id = k.id_wniosku
GROUP BY jezyk
ORDER BY prc_klientow DESC;

-- Jak często klient zmienia język (przeglądarki)?
-- (kolumny: email, liczba zmian, czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)

-- Pobranie danych potrzebnych do zrobienia zadania i pierwsze wyliczenia
WITH moje_dane AS (
  SELECT
    k.email email,
    w.data_utworzenia data_utw,
    w.jezyk jezyk,
    LAG(jezyk) OVER(PARTITION BY email ORDER BY w.data_utworzenia) poprz_jezyk,
    FIRST_VALUE(jezyk) OVER(PARTITION BY  email ORDER BY w.data_utworzenia) jezyk_1,
    FIRST_VALUE(jezyk) OVER(PARTITION BY  email ORDER BY w.data_utworzenia DESC) jezyk_2
  FROM wnioski w
  JOIN klienci k ON w.id = k.id_wniosku
  -- podzbiór danych w celu weryfikacji obliczeń
  -- WHERE email = 'kl_email1231344@ids.com' AND w.data_utworzenia < '2014-05-26 10:26:08.141383'::date
  ORDER BY 1, 2),

-- sprawdzenie czy pierwszy jezyk to ostatni
zmiana_jezyka AS (
  SELECT
    email,
    jezyk_1,
    jezyk_2,
    CASE WHEN jezyk_1 = jezyk_2 THEN TRUE ELSE FALSE END czy_pier_to_ost
  FROM moje_dane
  GROUP BY 1, 2, 3),

-- oblicznie liczby zmian
n_zmian AS (
  SELECT
    email,
    COUNT(CASE WHEN jezyk <> poprz_jezyk THEN 1 END) liczba_zmian
  FROM moje_dane
  GROUP BY 1)

-- połączenie wszystkich tabel
SELECT
  email,
  liczba_zmian,
  czy_pier_to_ost
FROM n_zmian
JOIN zmiana_jezyka
USING (email)
ORDER BY liczba_zmian DESC;