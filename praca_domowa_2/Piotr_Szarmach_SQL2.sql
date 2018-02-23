--1) Jaka data była 8 dni temu?
select now()::date - interval '8 days';

--2) Jaki dzień tygodnia był 3 miesiące temu?
select to_char(now()::date - interval '3 months', 'day');

--3) W którym tygodniu roku jest 01 stycznia 2017?
select to_char('01-01-2017'::date, 'WW');

--4) Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę)
select w.id, coalesce(sp.identyfikator_operator_operujacego, sp.identyfikator_operatora) from szczegoly_podrozy sp
join podroze p ON sp.id_podrozy = p.id
join wnioski w ON p.id_wniosku = w.id;

--5) Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku. 3 kolumny:
-- email, data 1wszego wniosku, data 2giego wniosku
with dane as (select distinct k.email as k_email, first_value(w.data_utworzenia) over(PARTITION BY k.email ORDER BY w.data_utworzenia asc) as first_date,
  nth_value(w.data_utworzenia, 2) over(PARTITION BY k.email ORDER BY w.data_utworzenia asc) as second_date
from klienci k
join wnioski w ON k.id_wniosku = w.id
GROUP BY k.email, w.data_utworzenia)

SELECT * FROM dane where second_date IS NOT NULL;

--6) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić kampanię marketingową,
-- która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000
--7) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić przymusową przerwę serwisową,
-- w sobotę 24 lutego nie będzie można utworzyć żadnych wniosków

--8) Ile (liczbowo) wniosków zostało utworzonych poniżej mediany liczonej z czasu między lotem i wnioskiem?
with roznice as (
    select percentile_cont(0.5) within group (order by extract(days from w.data_utworzenia - s2.data_wyjazdu)) as median
    from wnioski w
    JOIN podroze p ON w.id = p.id_wniosku
    JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
    where s2.czy_zaklocony = true
)

select count(case when extract(days from w.data_utworzenia - s2.data_wyjazdu) <
                       (select median from roznice) then 1 end) below_median
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.czy_zaklocony = true;

--9) Mając czas od utworzenia wniosku do jego analizy rzygotuj statystyke:
--jaka jest mediana czasu? a
--jaka jest srednia czasu? b
--jakie mamy wartości odstające? c
--ile jest wnioskow ponizej p75? d
--ile jest wnioskow powyzej p25? e
--czy te dane znacząco roznią się jesli rozbijemy je na zaakceptowane i odrzucone? f

with time_diff as (
select w.id as ident, a.data_utworzenia - w.data_utworzenia as diff from wnioski w
join analizy_wnioskow a ON w.id = a.id_wniosku
where a.data_utworzenia >= w.data_utworzenia),

stats as (
      SELECT
        percentile_cont(0.5)
        WITHIN GROUP (ORDER BY diff) AS median,
        percentile_cont(0.25)
        WITHIN GROUP (ORDER BY diff) AS Q1,
        percentile_cont(0.75)
        WITHIN GROUP (ORDER BY diff) AS Q3,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY diff)
        - percentile_cont(0.25) WITHIN GROUP (ORDER BY diff) AS IQ,
        avg(diff) as average
    from time_diff
  ),

--Im taking into consideration both mild and extreme outliers
  -- (src: http://www.itl.nist.gov/div898/handbook/prc/section1/prc16.htm)
outliers as (
    SELECT ident, case when diff <= (select Q1 - 1.5*IQ from stats )
                  OR diff >= (select Q3 + 1.5*IQ from stats ) then 1 else 0 end as is_outlier
    from time_diff
  ),

belowQ3 as (
    SELECT ident, case when diff < (select Q3 from stats) then 1 else 0 end as is_below_Q3
    from time_diff
),

aboveQ1 as (
    SELECT ident, case when diff > (select Q1 from stats) then 1 else 0 end as is_above_Q1
    from time_diff
  )

--select * from stats; -- a)3.05 sec b)1d 12h 21min 3.44 sec

--select is_outlier, COUNT(is_outlier) from outliers group by is_outlier; -- c) 15085 outliers

--select COUNT(*) from belowQ3 where is_below_Q3 = 1 -- d)63428

select COUNT(*) from aboveQ1 where is_above_Q1 = 1; -- e)63428

/***** ZAAKCEPTOWANE/ODRZUCONE ******/

with time_diff as (
select w.id as ident, a.data_utworzenia - w.data_utworzenia as diff from wnioski w
join analizy_wnioskow a ON w.id = a.id_wniosku
where a.data_utworzenia >= w.data_utworzenia and a.status = 'odrzucony'),

stats as (
      SELECT
        percentile_cont(0.5)
        WITHIN GROUP (ORDER BY diff) AS median,
        percentile_cont(0.25)
        WITHIN GROUP (ORDER BY diff) AS Q1,
        percentile_cont(0.75)
        WITHIN GROUP (ORDER BY diff) AS Q3,
        percentile_cont(0.75) WITHIN GROUP (ORDER BY diff)
        - percentile_cont(0.25) WITHIN GROUP (ORDER BY diff) AS IQ,
        avg(diff) as average
    from time_diff
  ),

--Im taking into consideration both mild and extreme outliers
  -- (src: http://www.itl.nist.gov/div898/handbook/prc/section1/prc16.htm)
outliers as (
    SELECT ident, case when diff <= (select Q1 - 1.5*IQ from stats )
                  OR diff >= (select Q3 + 1.5*IQ from stats ) then 1 else 0 end as is_outlier
    from time_diff
  ),

belowQ3 as (
    SELECT ident, case when diff < (select Q3 from stats) then 1 else 0 end as is_below_Q3
    from time_diff
),

aboveQ1 as (
    SELECT ident, case when diff > (select Q1 from stats) then 1 else 0 end as is_above_Q1
    from time_diff
  )

/* ACCEPTED:
   MEDIAN - 2.33 sec
   AVG - 1d 11h 55min 13.7 sec
   OUTLIERS - 12216
   BELOW Q3 - 58579
   ABOVE Q1 - 58579*/

/* REJECTED:
   MEDIAN - 1h 53.6 sec
   AVG - 1d 17h 32min 25.94 sec
   OUTLIERS - 760
   BELOW Q3 - 4859
   ABOVE Q1 - 4859*/

--select * from stats;

--select is_outlier, COUNT(is_outlier) from outliers group by is_outlier;

--select COUNT(*) from belowQ3 where is_below_Q3 = 1

select COUNT(*) from aboveQ1 where is_above_Q1 = 1;

--10) Chcę bardziej spersonalizować naszą stronę internetową pod wymagania klientów.
-- Aby to zrobić potrzebuję analizy dotyczącej języków używanych przez klientów:
--Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)
--Jak często klient zmienia język (przeglądarki)? (kolumny: email, liczba zmian,
-- czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)