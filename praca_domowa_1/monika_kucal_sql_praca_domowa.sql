--MONIKA KUCAL
--PRACA DOMOWA SQL

--OBOWIĄZKOWE
--Eksploracja danych

--1. Z którego kraju mamy najwięcej wniosków?
select w.kod_kraju,
  count(*) liczba_wnioskow
from wnioski w
where w.kod_kraju<>'ZZ'  --zakładam, że kod ZZ jest błędnym kodem kraju
group by 1
order by 2 desc
limit 1;

--2. Z którego języka mamy najwięcej wniosków?
select w.jezyk,
  count(*) liczba_wnioskow
from wnioski w
group by 1
order by 2 desc
limit 1;

--3. Ile % procent klientów podróżowało w celach biznesowych a ilu w celach prywatnych?
select w.typ_podrozy,
  round(count(*)/sum(count(*)) over ()::numeric,4) procent_wnioskow
from wnioski w
where w.typ_podrozy is not null -- zakładam, że chcę pominąć wnioski, gdzie typ podróży nie został podany
group by 1
order by 1;

--4. Jak procentowo rozkładają się źródła polecenia?
select w.zrodlo_polecenia,
  round(count(*)/sum(count(*)) over ()::numeric,4) procent_wnioskow
from wnioski w
where w.zrodlo_polecenia is not null -- zakładam, że chcę pominąć wnioski, gdzie źródło polecenia nie zostało podane
group by 1
order by 2 desc;

--5. Ile podróży to trasy złożone z jednego / dwóch / trzech / więcej tras?
with podroze as
(select s.id_podrozy, count(*) liczba_tras
 from szczegoly_podrozy s
group by id_podrozy
order by 2 desc)
  select case when liczba_tras>3 then '4 i więcej' else liczba_tras::varchar end liczba_tras,
    count(*) liczba_podrozy
  from podroze
  group by case when liczba_tras>3 then '4 i więcej' else liczba_tras::varchar end
  order by 1;

--6. Na które konto otrzymaliśmy najwięcej / najmniej rekompensaty?
with max as
(select s.konto, sum(s.kwota) kwota_rekompensaty
from szczegoly_rekompensat s
group by 1
order by 2 desc
limit 1),

min as
(select s.konto, sum(s.kwota) kwota_rekompensaty
from szczegoly_rekompensat s
group by 1
order by 2
limit 1)

  select m1.*, 'najwięcej rekompensaty' opis from max m1
union
  select m2.*, 'najmniej rekompensaty' opis from min m2
order by 2 desc;

--7. Który dzień jest rekordowym w firmie w kwestii utworzonych wniosków?
select to_char(w.data_utworzenia,'YYYY-MM-DD') data_utworzenia,
  count(*) liczba_wnioskow
from wnioski w
group by 1
order by 2 desc
limit 1;

--8. Który dzień jest rekordowym w firmie w kwestii otrzymanych rekompensat?
select to_char(s.data_otrzymania,'YYYY-MM-DD') data_otrzymania_rekompensaty,
  sum(s.kwota) kwota_rekompensaty
from szczegoly_rekompensat s
group by 1
order by 2 desc
limit 1;

--9. Jaka jest dystrubucja tygodniowa wniosków według kanałów? (liczba wniosków w danym tygodniu w każdym kanale)
select w.kanal,
  to_char(w.data_utworzenia,'WW'), -- zakładam, że chodzi o numer tygodnia w roku
  count(*) liczba_wnioskow
from wnioski w
group by 1,2;

--10. Lista wniosków przeterminowanych (przeterminowany = utworzony w naszej firmie powyżej 3 lat od daty podróży)
with data_podrozy as -- wyznaczam datę podrozy jako maksymalną datę wyjazdu w ramach jednej podróży
(select s.id_podrozy,
   max(s.data_wyjazdu) data_podrozy
 from szczegoly_podrozy s
   where s.data_wyjazdu between '2000-01-01' and now() -- eliminuję błędne daty w postaci 1012, 1970 oraz ewentualne większe niż data dzisiejsza
group by s.id_podrozy
order by 2 desc)

select w.id,
  to_char(w.data_utworzenia,'YYYY-MM-DD') data_utworzenia,
  to_char(s.data_podrozy,'YYYY-MM-DD') data_podrozy
from wnioski w
join podroze p on w.id = p.id_wniosku
join data_podrozy s on p.id = s.id_podrozy
where to_char(w.data_utworzenia,'YYYY-MM-DD')> to_char(s.data_podrozy+ interval '3 years','YYYY-MM-DD')
order by 2,3;

--Badanie powracających klientów

--1. Firmie zależy na tym, aby klienci do nas wracali.
--2. Jaka część naszych klientów to powracające osoby?
with wnioski_klientow as
(select k.email, count(*) liczba_wnioskow
 from klienci k
   group by 1)
select count(case when w.liczba_wnioskow>1 then w.email end)/count(distinct w.email)::numeric powracajacy_pct
from wnioski_klientow w;

--3. Jaka część naszych współpasażerów to osoby, które już wcześniej pojawiły się na jakimś wniosku?
with wspolpasazerowie_jako_klienci as
(select distinct w.email
 from wspolpasazerowie w
join klienci k on (w.email=k.email)
where w.data_utworzenia>k.data_utworzenia),

wielokrotni_wspolpasazerowie as
(select distinct w.email
 from wspolpasazerowie w
group by 1
having count(*)>1),

lista as
  (select email from wspolpasazerowie_jako_klienci
  UNION
   select email from wielokrotni_wspolpasazerowie)
select (select count(*) from lista)/count(distinct email)::numeric ponowni_wspolpasazerowie_pct
from wspolpasazerowie;

--4. Jaka część klientów pojawiła się na innych wnioskach jako współpasażer?
select count(distinct w.email)/count(distinct k.email)::numeric klienci_jako_wspolpasazerowie_pct
from klienci k
left join wspolpasazerowie w on (k.email=w.email);

--5. Czy jako nowy klient mający kilka zakłóceń, od razu składasz kilka wniosków? Jaki jest czas od złożenia pierwszego do kolejnego wniosku?
with lead as
(select w2.id, k.email, s2.identyfikator_podrozy, s2.data_utworzenia, count(w2.id) over (partition by k.email, s2.identyfikator_podrozy) liczba_wnioskow
from szczegoly_podrozy s2
join podroze p ON s2.id_podrozy = p.id
join wnioski w2 ON p.id_wniosku = w2.id
join klienci k ON w2.id = k.id_wniosku
  where s2.czy_zaklocony=TRUE
  and s2.identyfikator_podrozy not like '%--%'
  order by 4 desc)
  select l.id, l.email, l.identyfikator_podrozy,to_char(l.data_utworzenia,'YYYY-MM-DD'),
    extract(days from l.data_utworzenia - lag(l.data_utworzenia) over(partition by l.email, l.identyfikator_podrozy order by l.data_utworzenia)) czas_miedzy_wnioskami
  from lead l
  where l.liczba_wnioskow>1
  order by 2,3,4;


--DODATKOWE
--Wyłudzenia

--1. Jako data scientist jesteś także zobowiązany/a do sprawdzania danych pod kątem wyłudzeń (ten sam lot, ta sama osoba).
--   Znajdź listę współpasażerów próbujących stworzyć własny odrębny wniosek (na ten sam identifikator_podrozy), pomimo istnienia jako współpasażer na innym wniosku
with wspolpasazerowie as
(select w2.id id_wspolpasazera,
   w.id id_wniosku_jako_wspolpasazer,
   s2.identyfikator_podrozy id_podrozy_jako_wspolpasazer
from wspolpasazerowie w2
join wnioski w on (w.id=w2.id_wniosku)
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.identyfikator_podrozy not like '%--%')
select w.*,
  k.id_wniosku id_wniosku_jako_klient,
  s2.identyfikator_podrozy id_podrozy_jako_klient
from wspolpasazerowie w
join klienci k on w.id_wspolpasazera=k.id
join podroze p on k.id_wniosku = p.id_wniosku
join szczegoly_podrozy s2 on p.id = s2.id_podrozy
where s2.identyfikator_podrozy not like '%--%'
and w.id_podrozy_jako_wspolpasazer=s2.identyfikator_podrozy;


--Odrzucone wnioski

--1.  Chcemy przyjrzeć się odrzuconym wnioskom, które mają inny podobny (ten sam
--  identifikator_podrozy) wniosek, który jest wypłacony przed utworzeniem odrzuconego
--  wniosku. Przygotuj listę takich wniosków

with odrzucone as
(select w.id,
      to_char(w.data_utworzenia,'YYYY-MM-DD') data_utworzenia,
      w.stan_wniosku,
   s2.identyfikator_podrozy
from wnioski w
  join podroze p ON w.id = p.id_wniosku
  join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where w.stan_wniosku like 'odrzucony%'
and s2.identyfikator_podrozy not like '%--%'),

wyplacone AS
(select w.id,
      to_char(sr.data_otrzymania,'YYYY-MM-DD') data_otrzymania_rekompensaty,
    w.stan_wniosku,
   s2.identyfikator_podrozy
from wnioski w
  join podroze p ON w.id = p.id_wniosku
  join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
  join rekompensaty r ON w.id = r.id_wniosku
  join szczegoly_rekompensat sr ON r.id = sr.id_rekompensaty
where w.stan_wniosku ='wyplacony'
and s2.identyfikator_podrozy not like '%--%')

select o.*, w.*
from odrzucone o
join wyplacone w on (o.identyfikator_podrozy=w.identyfikator_podrozy)
where o.data_utworzenia>w.data_otrzymania_rekompensaty;