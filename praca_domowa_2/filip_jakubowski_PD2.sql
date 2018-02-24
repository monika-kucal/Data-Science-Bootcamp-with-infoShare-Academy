OBOWIAZKOWE:
--1) Jaka data była 8 dni temu?
SELECT to_char(now()::date - INTERVAL '8day', 'YYYY-MM-DD')::date;

--2) Jaki dzień tygodnia był 3 miesiące temu?
SELECT to_char(now()::date - INTERVAL '3 month','Day');

--3) W którym tygodniu roku jest 01 stycznia 2017?
SELECT to_char('2017-01-01'::date, 'ww');

--4) Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę)
SELECT wnioski.id, coalesce(s2.identyfikator_operator_operujacego,s2.identyfikator_operator_operujacego) operator_przejazdu
--  dodalem coalesce bo inaczej podawalo mi tylko identyfikatory operatorow lub jak je porownywalem zanaczalo jako true
    FROM wnioski
    JOIN podroze p ON wnioski.id = p.id_wniosku
    JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
    WHERE coalesce(s2.identyfikator_operator_operujacego,s2.identyfikator_operator_operujacego) IS NOT NULL
ORDER BY 1;

--5) Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku. 3 kolumny:
--email, data 1wszego wniosku, data 2giego wniosku
SELECT email,
first_value(w2.data_utworzenia) OVER (PARTITION BY email ORDER BY w2.data_utworzenia)::date as data_1_wniosku,
nth_value(w2.data_utworzenia,2) OVER (PARTITION BY email ORDER BY w2.data_utworzenia)::date as data_2_wniosku
-- wykorzystanie first i nth jako kolejnego porowna mi wszystkie emaile i daty pierwszego i kolejneg utworzenia wniosku
FROM klienci
JOIN wnioski w2 ON klienci.id_wniosku = w2.id
ORDER BY 2;


6) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić kampanię marketingową,
która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000

WITH daty AS (
     SELECT generate_series(date_trunc('day','2018-01-20'::date),
      date_trunc('month',now())+INTERVAL '1 month'-INTERVAL '1 day','1 day')::date AS wygenerowana_data),

aktualne_wnioski AS (
    SELECT to_char(w.data_utworzenia,'YYYY-MM-DD')::date data_wniosku,
     count(*) liczba_wnioskow
    FROM wnioski w
    WHERE data_utworzenia>'2018-02-09'::date-INTERVAL'3 weeks'+INTERVAL '1 day'
    GROUP BY 1),

lista_z_wnioskami AS (
  SELECT d.wygenerowana_data, coalesce(w.liczba_wnioskow,0) liczba_wnioskow,
     sum(w.liczba_wnioskow) OVER (ORDER BY d.wygenerowana_data) skumulowana_liczba_wnioskow
    FROM daty d
    LEFT JOIN aktualne_wnioski w ON d.wygenerowana_data=w.data_wniosku
    ORDER BY 1),

srednie_tygodniowo AS (
    SELECT to_char(wygenerowana_data,'Day') dzien_tygodnia,
    round(avg(liczba_wnioskow)) srednia_liczba_wnioskow,
    count(*) liczba_wnioskow
    FROM lista_z_wnioskami
    WHERE wygenerowana_data <='2018-02-09'::date
    GROUP BY 1
ORDER BY 1)

--zakladmy ze liczba wnioskow bedzie 1000 do 2018-02-26 czyli wzrosnie o 456 wzgledem 544 ktore mamy obecnie wygenerowane
-- na dzien 02-26

SELECT to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
  CASE WHEN l.wygenerowana_data<='2018-02-09' THEN l.liczba_wnioskow ELSE s.srednia_liczba_wnioskow END
  + CASE WHEN l.wygenerowana_data='2018-02-26' THEN 456 ELSE 0 END liczba_wnioskow,
  -- zalezy mi na tym aby 26 byla wartosc 1000 wygenerowanych wnioskow
  sum(CASE WHEN l.wygenerowana_data<='2018-02-09' THEN l.liczba_wnioskow ELSE s.srednia_liczba_wnioskow END
  + CASE WHEN l.wygenerowana_data='2018-02-26' THEN 456 ELSE 0 END ) OVER (PARTITION BY date_trunc('month',l.wygenerowana_data)
    ORDER BY l.wygenerowana_data) skumulowana_liczba_wnioskow_miesiecznie
    FROM lista_z_wnioskami l
    JOIN srednie_tygodniowo s ON to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
ORDER BY 1;

7) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić przymusową przerwę serwisową, w sobotę 24
lutego nie będzie można utworzyć żadnych wniosków

WITH daty AS (
    SELECT generate_series(date_trunc('day','2018-01-20'::date),
    date_trunc('month',now())+INTERVAL '1 month'-INTERVAL '1 day','1 day')::date AS wygenerowana_data),

aktualne_wnioski AS (
    SELECT to_char(w.data_utworzenia,'YYYY-MM-DD')::date data_wniosku,
     count(*) liczba_wnioskow
    FROM wnioski w
    WHERE data_utworzenia>'2018-02-09'::date-INTERVAL'3 weeks'+INTERVAL'1 day'
GROUP BY 1),

lista_z_wnioskami AS (
    SELECT d.wygenerowana_data, coalesce(w.liczba_wnioskow,0) liczba_wnioskow,
     sum(w.liczba_wnioskow) OVER (ORDER BY d.wygenerowana_data) skumulowana_liczba_wnioskow
    FROM daty d
    LEFT JOIN aktualne_wnioski w ON d.wygenerowana_data=w.data_wniosku
    ORDER BY 1),

srednie_tygodniowo AS  (
    SELECT to_char(wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(liczba_wnioskow)) srednia_liczba_wnioskow,
   count(*) liczba_wnioskow
    FROM lista_z_wnioskami
    WHERE wygenerowana_data <='2018-02-09'::date
GROUP BY 1
ORDER BY 1)

--24-02-2018 nie tworzymy wnioskow

SELECT to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
  CASE  WHEN l.wygenerowana_data<='2018-02-09' THEN l.liczba_wnioskow
  WHEN l.wygenerowana_data='2018-02-24'THEN 0 ELSE s.srednia_liczba_wnioskow END ,
  sum(CASE WHEN l.wygenerowana_data<='2018-02-09' THEN l.liczba_wnioskow
  WHEN l.wygenerowana_data='2018-02-24'THEN 0 ELSE s.srednia_liczba_wnioskow END ) OVER (PARTITION BY date_trunc('month',l.wygenerowana_data)
  ORDER BY l.wygenerowana_data) skumulowana_liczba_wnioskow_miesiecznie
  FROM lista_z_wnioskami l
  JOIN srednie_tygodniowo s ON to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
ORDER BY 1;

8) Ile (liczbowo) wniosków zostało utworzonych poniżej mediany liczonej z czasu między lotem i wnioskiem?


9) Mając czas od utworzenia wniosku do jego analizy rzygotuj statystyke:

jaka jest mediana czasu?
jaka jest srednia czasu?
jakie mamy wartości odstające?
ile jest wnioskow ponizej p75?
ile jest wnioskow powyzej p25?
czy te dane znacząco roznią się jesli rozbijemy je na zaakceptowane i odrzucone?

10) Chcę bardziej spersonalizować naszą stronę internetową pod wymagania klientów.
Aby to zrobić potrzebuję analizy dotyczącej języków używanych przez klientów:
Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)

SELECT jezyk,
  count(DISTINCT email) liczba_klientow,
  round(count(DISTINCT email)/sum(count(DISTINCT email)) OVER ()::NUMERIC,5)  procent_klientow
FROM wnioski
JOIN klienci ON wnioski.id = klienci.id_wniosku
GROUP BY 1;

Jak często klient zmienia język (przeglądarki)? (kolumny: email, liczba zmian, czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)

WITH zmiany AS (
  SELECT k.email,
  CASE WHEN w.jezyk <> lag(w.jezyk) OVER (PARTITION BY k.email ORDER BY w.data_utworzenia) THEN 1 END zmiany_jezyka
  FROM wnioski w
  JOIN klienci k ON w.id = k.id_wniosku
  ORDER BY 2),

ten_sam_jezyk AS (
  SELECT DISTINCT k.email,
  CASE WHEN first_value(w.jezyk) OVER (PARTITION BY k.email ORDER BY w.data_utworzenia) =
  first_value(w.jezyk) OVER (PARTITION BY k.email ORDER BY w.data_utworzenia ) THEN 1 ELSE 0 END ten_sam_jezyk
  FROM klienci k
  JOIN wnioski w ON k.id_wniosku = w.id)

SELECT z.email,
  sum(z.zmiany_jezyka) liczba_zmian_jezyka,
  t.ten_sam_jezyk
FROM zmiany z
JOIN ten_sam_jezyk t ON (z.email=t.email)
GROUP BY 1,3;

DODATKOWE:
1) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby leadów (także na aktualny miesiąc, predykcja do k
ońca miesiąca)
2) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby zanalizowanych wniosków (także na aktualny miesiąc,
predykcja do końca miesiąca)
3) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby wysłanych maili w kampaniach (także na aktualny
miesiąc, predykcja do końca miesiąca)