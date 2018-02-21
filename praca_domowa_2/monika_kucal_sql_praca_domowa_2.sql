--MONIKA KUCAL
--PRACA DOMOWA SQL 2



--OBOWIAZKOWE:
--1) Jaka data była 8 dni temu?
select (now()-interval'8 days')::date data_8_dni_temu;



--2) Jaki dzień tygodnia był 3 miesiące temu?
select to_char((now()-interval'3 months'),'Day') dzien_3_miesiace_temu;



--3) W którym tygodniu roku jest 01 stycznia 2017?
select to_char('2017-01-01'::date,'WW') tydzien_roku;



--4) Podaj listę wniosków z właściwym operatorem (który rzeczywiście przeprowadził trasę)
select w.id, coalesce(s2.identyfikator_operator_operujacego,s2.identyfikator_operatora) nazwa_operatora
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
order by 2 desc, 1;



--5) Przygotuj listę klientów z datą utworzenia ich pierwszego i drugiego wniosku. 3 kolumny: email, data 1wszego wniosku, data 2giego wniosku
select distinct k.email,
first_value(w.data_utworzenia) over (partition by k.email order by w.data_utworzenia)::date data_1_wniosku,
nth_value(w.data_utworzenia,2) over (partition by k.email order by w.data_utworzenia)::date data_2_wniosku
from klienci k
join wnioski w ON k.id_wniosku = w.id
order by 3,2,1;



--6) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić kampanię marketingową, która odbędzie się 26 lutego - przewidywana liczba wniosków z niej to 1000
with daty as
(select generate_series(date_trunc('day','2018-01-20'::date),
                       date_trunc('month',now())+interval '1 month'-interval '1 day',
                       '1 day')::date as wygenerowana_data),
aktualne_wnioski AS
  (select to_char(w.data_utworzenia,'YYYY-MM-DD')::date data_wniosku,
     count(*) liczba_wnioskow
from wnioski w
  where data_utworzenia>'2018-02-09'::date-interval '3 weeks'+interval '1 day'
group by 1),

lista_z_wnioskami as
  (select d.wygenerowana_data, coalesce(w.liczba_wnioskow,0) liczba_wnioskow,
     sum(w.liczba_wnioskow) over (order by d.wygenerowana_data) skumulowana_liczba_wnioskow
from daty d
left join aktualne_wnioski w on d.wygenerowana_data=w.data_wniosku
order by 1),

srednie_tygodniowo as
(select to_char(wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(liczba_wnioskow)) srednia_liczba_wnioskow,
   count(*) liczba_wnioskow
from lista_z_wnioskami
  where wygenerowana_data <='2018-02-09'::date
group by 1
order by 1)

  /*
  w tym miejscu modyfikuje kod
  zakładam, że kampania przyniesie dodatkową liczbę wniosków,
  a więc liczba wniosków w dniu 26/02/2018 będzie większa o 1000 sztuk,
  czyli wyniesie 1544 zamiast 544, co da skumulowaną sumę w lutym 11186 zamiast 10186
  */

select to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
  --zmiana tutaj (liczba_wnioskow oraz skumulowana_liczba_wnioskow)
  case when l.wygenerowana_data<='2018-02-09' then l.liczba_wnioskow else s.srednia_liczba_wnioskow end
  + case when l.wygenerowana_data='2018-02-26' then 1000 else 0 end liczba_wnioskow,
  sum(case when l.wygenerowana_data<='2018-02-09' then l.liczba_wnioskow else s.srednia_liczba_wnioskow end + case when l.wygenerowana_data='2018-02-26' then 1000 else 0 end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_liczba_wnioskow_miesiecznie
from lista_z_wnioskami l
join srednie_tygodniowo s on to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
order by 1;



--7) Używając pełen kod do predykcji wniosków, zmień go tak aby uwzględnić przymusową przerwę serwisową, w sobotę 24 lutego nie będzie można utworzyć żadnych wniosków
with daty as
(select generate_series(date_trunc('day','2018-01-20'::date),
                       date_trunc('month',now())+interval '1 month'-interval '1 day',
                       '1 day')::date as wygenerowana_data),
aktualne_wnioski AS
  (select to_char(w.data_utworzenia,'YYYY-MM-DD')::date data_wniosku,
     count(*) liczba_wnioskow
from wnioski w
  where data_utworzenia>'2018-02-09'::date-interval '3 weeks'+interval '1 day'
group by 1),

lista_z_wnioskami as
  (select d.wygenerowana_data, coalesce(w.liczba_wnioskow,0) liczba_wnioskow,
     sum(w.liczba_wnioskow) over (order by d.wygenerowana_data) skumulowana_liczba_wnioskow
from daty d
left join aktualne_wnioski w on d.wygenerowana_data=w.data_wniosku
order by 1),

srednie_tygodniowo as
(select to_char(wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(liczba_wnioskow)) srednia_liczba_wnioskow,
   count(*) liczba_wnioskow
from lista_z_wnioskami
  where wygenerowana_data <='2018-02-09'::date
group by 1
order by 1)

  /*
  w tym miejscu modyfikuje kod
  zakładam, że liczba wniosków w dniu 24/02/2018 wyniesie 0 sztuk,
  co da skumulowaną sumę w lutym 10185 zamiast 10186
  */

select to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
  --zmiana tutaj (liczba_wnioskow oraz skumulowana_liczba_wnioskow)
  case when l.wygenerowana_data<='2018-02-09' then l.liczba_wnioskow when l.wygenerowana_data='2018-02-24' then 0 else s.srednia_liczba_wnioskow end liczba_wnioskow,
  sum(case when l.wygenerowana_data<='2018-02-09' then l.liczba_wnioskow when l.wygenerowana_data='2018-02-24' then 0 else s.srednia_liczba_wnioskow end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_liczba_wnioskow_miesiecznie
from lista_z_wnioskami l
join srednie_tygodniowo s on to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
order by 1;



--8) Ile (liczbowo) wniosków zostało utworzonych poniżej mediany liczonej z czasu między lotem i wnioskiem?
with mediana_czas AS
(select
  percentile_cont(0.5) within group (order by extract(days from (w2.data_utworzenia- s2.data_wyjazdu))) mediana
from wnioski w2
join podroze p ON w2.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.czy_zaklocony=true)

select count(case when extract(days from (w2.data_utworzenia- s2.data_wyjazdu))< m.mediana then w2.id end) liczba_wnioskow_ponizej_mediany_czas,
  count(*) total,
  round(count(case when extract(days from (w2.data_utworzenia- s2.data_wyjazdu))< m.mediana then w2.id end)/count(*)::numeric,4) wnioski_ponizej_mediany_czas_pct
from wnioski w2
join podroze p ON w2.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
join mediana_czas m on 1=1
where s2.czy_zaklocony=true;

--88077 sposrod 179743 wnioskow ponizej mediany czasu lot-wniosek, co stanowi 49%, a mniej niż 50%, ponieważ
--1900 wnioskow mialo czas wlot-wniosek rowny medianie czasu



/*9) Mając czas od utworzenia wniosku do jego analizy przygotuj statystyke:
    jaka jest mediana czasu?
    jaka jest srednia czasu?
    jakie mamy wartości odstające?
    ile jest wnioskow ponizej p75?
    ile jest wnioskow powyzej p25?
    czy te dane znacząco roznią się jesli rozbijemy je na zaakceptowane i odrzucone?*/

--ANALIZA WSZYSTKICH WNIOSKOW PRZEANALIZOWANYCH

with czasy as
(select w2.id, a.data_utworzenia, w2.data_utworzenia, a.data_utworzenia-w2.data_utworzenia czas --czas miedzy data utworzenia wniosku a data utworzenia analizy
from wnioski w2
join analizy_wnioskow a ON w2.id = a.id_wniosku
      where a.data_utworzenia>=w2.data_utworzenia --eliminuje bledne przypadki, gdzie data utworzenia analizy jest wczesniejsza niz data utworzenia wniosku
order by 2),

statystyki as
(select percentile_cont(0.5) within group (order by c.czas) mediana,
  avg(c.czas) srednia,
  percentile_cont(0.25) within group (order by c.czas) kwartyl_1,
  percentile_cont(0.75) within group (order by c.czas) kwartyl_3,
  percentile_cont(0.75) within group (order by c.czas)-percentile_cont(0.25) within group (order by c.czas) rozstep_cwiartkowy
from czasy c),
--select * from statystyki
  --mediana: 3.053203 secs
  --srednia: 1 days 12 hours 21 mins 3.443868 secs

outliers as --wartosci odstajace wyznaczam jako te, ktore wypadaja poza +/-1.5 krotnosc rozstepu cwiartkowego
  (select c.id, c.czas, s.rozstep_cwiartkowy,
     case when c.czas <= s.kwartyl_1 - 1.5*s.rozstep_cwiartkowy or c.czas >= s.kwartyl_3 + 1.5*s.rozstep_cwiartkowy then 1 end czy_outlier
   from czasy c
join statystyki s on 1=1),

--select count(czy_outlier), count(*), round(count(czy_outlier)/count(*)::numeric,4)
--from outliers;

--liczba wartosci odstajacych:
  --  15085 spośród 84585 przeanalizowanych wnioskow, co stanowi 17.83%

ponizej_Q3_powyzej_Q1 as
  (select c.id,
     case when c.czas < s.kwartyl_3 then 1 end czy_ponizej_Q3,
    case when c.czas > s.kwartyl_1 then 1 end czy_powyzej_Q1
   from czasy c
join statystyki s on 1=1)

select count(czy_ponizej_Q3) ile_ponizej_Q3,
  count(czy_powyzej_Q1) ile_powyzej_Q3,
  count(*) total,
  round(count(czy_ponizej_Q3)/count(*)::numeric,4) ponizej_Q3_pct,
  round(count(czy_powyzej_Q1)/count(*)::numeric,4) powyzej_Q1_pct
from ponizej_Q3_powyzej_Q1;
--liczba wnioskow ponizej Q3: 63438 co stanowi 75%
--liczba wnioskow powyzej Q1: 63438 co stanowi również 75%


--ANALIZA W PODZIALE NA ZAAKCEPTOWANE/ODRZUCONE

with czasy as
(select w2.id, a.status, a.data_utworzenia, w2.data_utworzenia, a.data_utworzenia-w2.data_utworzenia czas --czas miedzy data utworzenia wniosku a data utworzenia analizy
from wnioski w2
join analizy_wnioskow a ON w2.id = a.id_wniosku
      where a.data_utworzenia>=w2.data_utworzenia --eliminuje bledne przypadki, gdzie data utworzenia analizy jest wczesniejsza niz data utworzenia wniosku
order by 2),

statystyki as
(select c.status, percentile_cont(0.5) within group (order by c.czas) mediana,
  avg(c.czas) srednia,
  percentile_cont(0.25) within group (order by c.czas) kwartyl_1,
  percentile_cont(0.75) within group (order by c.czas) kwartyl_3,
  percentile_cont(0.75) within group (order by c.czas)-percentile_cont(0.25) within group (order by c.czas) rozstep_cwiartkowy
from czasy c
  group by 1),
--select * from statystyki;
  --mediana - na podstawie mediany mozna stwierdzic, ze czas dla odrzuconych jest dluzszy niz dla zaakceptowanych
  -- odrzucone: 1 hours 0 mins 53.606726 secs
  -- zaakceptowane: 2.333323 secs
  --srednia - na podstawie sredniej rowniez mozna stwierdzic, ze czas dla odrzuconych jest dluzszy niz dla zaakceptowanych,
            --ale srednia jest wrazliwa na wartosci odstajace
  -- odrzucone: 1 days 17 hours 32 mins 25.943935 secs
  -- zaakceptowane: 1 days 11 hours 55 mins 13.704823 secs

outliers as --wartosci odstajace wyznaczam jako te, ktore wypadaja poza +/-1.5 krotnosc rozstepu cwiartkowego
  (select c.id, c.status, c.czas, s.rozstep_cwiartkowy,
     case when c.czas <= s.kwartyl_1 - 1.5*s.rozstep_cwiartkowy or c.czas >= s.kwartyl_3 + 1.5*s.rozstep_cwiartkowy then 1 end czy_outlier
   from czasy c
join statystyki s on c.status=s.status),

--select status, count(czy_outlier), count(*), round(count(czy_outlier)/count(*)::numeric,4)
--from outliers
--group by 1;
--liczba wartosci odstajacych:
-- odrzucone: 760 spośród 6479 odrzuconych wnioskow, co stanowi 11.73%
-- zaakceptowane: 12216 spośród 78106 zaakceptowanych wnioskow, co stanowi 15.64%
-- grupa odrzuconych jest bardziej zroznicowana, wiec mniejszy odsetek wnioskow jest wartosciami odstajacymi
-- grupa zaakceptowanych jest mniej zroznicowana, wiec wiekszy odsetek wnioskow jest wartosciami odstajacymi

ponizej_Q3_powyzej_Q1 as
  (select c.id,c.status,
     case when c.czas < s.kwartyl_3 then 1 end czy_ponizej_Q3,
    case when c.czas > s.kwartyl_1 then 1 end czy_powyzej_Q1
   from czasy c
join statystyki s on c.status=s.status)

select status,
  count(czy_ponizej_Q3) ile_ponizej_Q3,
  count(czy_powyzej_Q1) ile_powyzej_Q3,
  count(*) total,
  round(count(czy_ponizej_Q3)/count(*)::numeric,4) ponizej_Q3_pct,
  round(count(czy_powyzej_Q1)/count(*)::numeric,4) powyzej_Q1_pct
from ponizej_Q3_powyzej_Q1
group by 1;
--liczba wnioskow ponizej Q3:
  --odrzucone: 4859 co stanowi 75%
  --zaakceptowane: 58579 co stanowi 75%
--liczba wnioskow powyzej Q1:
  --odrzucone: 4859 co stanowi 75%
  --zaakceptowane: 58579 co stanowi 75%



--10) Chcę bardziej spersonalizować naszą stronę internetową pod wymagania klientów.
-- Aby to zrobić potrzebuję analizy dotyczącej języków używanych przez klientów:
-- Jakich języków używają klienci? (kolumny: jezyk, liczba klientow, % klientow)
-- Jak często klient zmienia język (przeglądarki)? (kolumny: email, liczba zmian, czy ostatni jezyk wniosku zgadza sie z pierwszym jezykiem wniosku)
select w.jezyk,
  count(distinct k.email) liczba_klientow,
  count(distinct k.email)/sum(count(distinct k.email)) over () klienci_pct
from wnioski w
join klienci k ON w.id = k.id_wniosku
group by 1
order by 2 desc;

with liczba_zmian as
(select k.email,
  case when w.jezyk <> lag(w.jezyk) over (partition by k.email order by w.data_utworzenia) then 1 end liczba_zmian_jezyka
from wnioski w
join klienci k ON w.id = k.id_wniosku
order by 2 ),

czy_jezyk_ten_sam AS
  (select distinct k.email,
  case when first_value(w.jezyk) over (partition by k.email order by w.data_utworzenia)=
  first_value(w.jezyk) over (partition by k.email order by w.data_utworzenia desc) then true else false end czy_jezyk_ten_sam
  from klienci k
  join wnioski w ON k.id_wniosku = w.id)

select l.email,
  sum(l.liczba_zmian_jezyka) liczba_zmian_jezyka,
  c.czy_jezyk_ten_sam
from liczba_zmian l
join czy_jezyk_ten_sam c on (l.email=c.email)
group by 1,3
order by 2;



--DODATKOWE:
--1) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby leadów (także na aktualny miesiąc, predykcja do końca miesiąca)

--OPIS ZMIAN
-- Oprócz scenariusza średniej z 3 tygodni zastosowałam również scenariusz optymistyczny i pesymistyczny (max, min z 3 tygodni).
-- Założyłam, że w środy będzie można zwiększyć liczbę lead'ów o 15%.
-- W kodzie uzmienniłam daty startu prognozy/daty startu proby historycznych w zaleznosci od dostepnych danych (data_lead, itd.)

with max_data_lead AS --wyznaczam maksymalna date, dla ktorej mam lead'y
  (select max(data_wysylki) max_data_wysylki
      from m_lead
        where data_wysylki<now()),

daty as
(select generate_series(date_trunc('day',l.max_data_wysylki::date-interval '3 weeks'+interval '1 day'),--generuje od 3 tygodni wsteczn od daty dla ktorej koncza sie dane rzeczywiste
                       date_trunc('month',now())+interval '1 month'-interval '1 day',
                       '1 day')::date as wygenerowana_data
  from max_data_lead l),

aktualne_lead AS
  (select to_char(l.data_wysylki,'YYYY-MM-DD')::date data_wysylki,
     count(*) liczba_leadow
from m_lead l
  join max_data_lead m on 1=1
  where l.data_wysylki>m.max_data_wysylki::date-interval '3 weeks'+interval '1 day' --robie prognoze z 3 tygodni wstecz od max daty wysylki lead'a
  and l.data_wysylki<now() --eliminuje bledne daty
group by 1),

lista_z_lead as
  (select d.wygenerowana_data, coalesce(l.liczba_leadow,0) liczba_leadow,
     sum(l.liczba_leadow) over (partition by date_trunc('month',d.wygenerowana_data) order by d.wygenerowana_data) skumulowana_liczba_leadow
from daty d
left join aktualne_lead l on d.wygenerowana_data=l.data_wysylki
order by 1),

avg_min_max_tygodniowo as
(select to_char(l.wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(l.liczba_leadow)) avg_liczba_lead,
    round(max(l.liczba_leadow)) max_liczba_lead,
    round(min(l.liczba_leadow)) min_liczba_lead,
   count(*) z_ilu_dni
from lista_z_lead l
  join max_data_lead m on 1=1
  where l.wygenerowana_data <=m.max_data_wysylki::date
group by 1
order by 1)

select to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
  case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.max_liczba_lead) end max_liczba_leadow,
  sum(case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.max_liczba_lead) end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_max_liczba_leadow_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.avg_liczba_lead) end avg_liczba_leadow,
  sum(case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.avg_liczba_lead) end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_avg_liczba_leadow_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.min_liczba_lead) end min_liczba_leadow,
  sum(case when l.wygenerowana_data<=m.max_data_wysylki then l.liczba_leadow else round(case when to_char(l.wygenerowana_data,'ID')='3' then 1.15 else 1 end * s.min_liczba_lead) end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_min_liczba_leadow_miesiecznie
from lista_z_lead l
join avg_min_max_tygodniowo s on to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
  join max_data_lead m on 1=1
order by 1;



--2) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby zanalizowanych wniosków (także na aktualny miesiąc, predykcja do końca miesiąca)

--OPIS ZMIAN
-- Oprócz scenariusza średniej z 3 tygodni zastosowałam również scenariusz optymistyczny i pesymistyczny (max, min z 3 tygodni).
-- Założyłam, że w niedzielę nie będą analizowane żadne wnioski.
-- W kodzie uzmienniłam daty startu prognozy/daty startu proby historycznych w zaleznosci od dostepnych danych (data_analizy, itd.)

with max_data_analizy AS --wyznaczam maksymalna date, dla ktorej mam analizy
  (select max(data_utworzenia) max_data_utworzenia
      from analizy_wnioskow
        where data_utworzenia<now()),

daty as
(select generate_series(date_trunc('day',l.max_data_utworzenia::date-interval '3 weeks'+interval '1 day'),--generuje od 3 tygodni wsteczn od daty dla ktorej koncza sie dane rzeczywiste
                       date_trunc('month',now())+interval '1 month'-interval '1 day',
                       '1 day')::date as wygenerowana_data
  from max_data_analizy l),

aktualne_analizy AS
  (select to_char(l.data_utworzenia,'YYYY-MM-DD')::date data_utworzenia,
     count(*) liczba_analiz
from analizy_wnioskow l
  join max_data_analizy m on 1=1
  where l.data_utworzenia>m.max_data_utworzenia::date-interval '3 weeks'+interval '1 day' --robie prognoze z 3 tygodni wstecz od max daty analizy
  and l.data_utworzenia<now() --eliminuje bledne daty
group by 1),

lista_z_analizami as
  (select d.wygenerowana_data, coalesce(l.liczba_analiz,0) liczba_analiz,
     sum(l.liczba_analiz) over (partition by date_trunc('month',d.wygenerowana_data) order by d.wygenerowana_data) skumulowana_liczba_analiz
from daty d
left join aktualne_analizy l on d.wygenerowana_data=l.data_utworzenia
order by 1),

avg_min_max_tygodniowo as
(select to_char(l.wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(l.liczba_analiz)) avg_liczba_analiz,
    round(max(l.liczba_analiz)) max_liczba_analiz,
    round(min(l.liczba_analiz)) min_liczba_analiz,
   count(*) z_ilu_dni
from lista_z_analizami l
  join max_data_analizy m on 1=1
  where l.wygenerowana_data <=m.max_data_utworzenia::date
group by 1
order by 1)

select to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
   case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.max_liczba_analiz end max_liczba_analiz,
  sum(case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.max_liczba_analiz end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_max_liczba_analiz_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.avg_liczba_analiz end avg_liczba_analiz,
  sum(case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.avg_liczba_analiz end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_avg_liczba_analiz_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.min_liczba_analiz end min_liczba_analiz,
  sum(case when l.wygenerowana_data<=m.max_data_utworzenia then l.liczba_analiz when to_char(l.wygenerowana_data,'ID')='7' then 0 else s.min_liczba_analiz end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_min_liczba_analiz_miesiecznie
from lista_z_analizami l
join avg_min_max_tygodniowo s on to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
  join max_data_analizy m on 1=1
order by 1;

--3) Analogicznie do przewidywania wniosków: wykonaj predykcję liczby wysłanych maili w kampaniach (także na aktualny miesiąc, predykcja do końca miesiąca)

--OPIS ZMIAN
-- Oprócz scenariusza średniej z 3 tygodni zastosowałam również scenariusz optymistyczny i pesymistyczny (max, min z 3 tygodni).
-- Założyłam, że dodatkowa kampania obejmująca 600 maili odbędzie się 28/02/2018.
-- W kodzie uzmienniłam daty startu prognozy/daty startu proby historycznych w zaleznosci od dostepnych danych (data_maila, itd.)

with max_data_maila AS --wyznaczam maksymalna date, dla ktorej mam analizy
  (select max(k.data_kampanii) max_data_kampanii
      from m_kampanie k
        join m_email e ON k.id = e.id_kampanii
        where k.status='wyslane'),

daty as
(select generate_series(date_trunc('day',l.max_data_kampanii::date-interval '3 weeks'+interval '1 day'),--generuje od 3 tygodni wstecz od daty dla ktorej koncza sie dane rzeczywiste
                       date_trunc('month',now())+interval '1 month'-interval '1 day',
                       '1 day')::date as wygenerowana_data
  from max_data_maila l),

aktualne_maile AS
  (select to_char(k.data_kampanii,'YYYY-MM-DD')::date data_kampanii,
     count(*) liczba_maili
from m_kampanie k
  join m_email e on k.id = e.id_kampanii
  join max_data_maila m on 1=1
  where k.data_kampanii>m.max_data_kampanii::date-interval '3 weeks'+interval '1 day' --robie prognoze z 3 tygodni wstecz od max daty analizy
  and k.data_kampanii<now() --eliminuje bledne daty
  and k.status='wyslane'
group by 1),

lista_z_mailami as
  (select d.wygenerowana_data, coalesce(m.liczba_maili,0) liczba_maili,
     sum(m.liczba_maili) over (partition by date_trunc('month',d.wygenerowana_data) order by d.wygenerowana_data) skumulowana_liczba_maili
from daty d
left join aktualne_maile m on d.wygenerowana_data=m.data_kampanii
order by 1),

avg_min_max_tygodniowo as
(select to_char(l.wygenerowana_data,'Day') dzien_tygodnia,
   round(avg(l.liczba_maili)) avg_liczba_maili,
    round(max(l.liczba_maili)) max_liczba_maili,
    round(min(l.liczba_maili)) min_liczba_maili,
   count(*) z_ilu_dni
from lista_z_mailami l
  join max_data_maila m on 1=1
  where l.wygenerowana_data <=m.max_data_kampanii::date
group by 1
order by 1)

select to_char(l.wygenerowana_data,'YYYY-MM-DD Day') dzien,
   case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.max_liczba_maili else s.max_liczba_maili end max_liczba_maili,
  sum(case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.max_liczba_maili else s.max_liczba_maili end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_max_liczba_maili_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.avg_liczba_maili else s.avg_liczba_maili end avg_liczba_maili,
  sum(case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.avg_liczba_maili else s.avg_liczba_maili end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_avg_liczba_maili_miesiecznie,
   case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.min_liczba_maili else s.min_liczba_maili end min_liczba_maili,
  sum(case when l.wygenerowana_data<=m.max_data_kampanii then l.liczba_maili when l.wygenerowana_data='2018-02-28' then 600 + s.min_liczba_maili else s.min_liczba_maili end) over (partition by date_trunc('month',l.wygenerowana_data) order by l.wygenerowana_data) skumulowana_min_liczba_maili_miesiecznie
from lista_z_mailami l
join avg_min_max_tygodniowo s on to_char(l.wygenerowana_data,'Day')=s.dzien_tygodnia
  join max_data_maila m on 1=1
order by 1;