--1. Z którego kraju mamy najwięcej wniosków?
SELECT w.kod_kraju, COUNT(*) as liczba_wnioskow
FROM wnioski w
group by w.kod_kraju
ORDER BY 2 desc;

--2. Z którego języka mamy najwięcej wniosków?
SELECT w.jezyk, COUNT(*) as liczba_wnioskow
FROM wnioski w
group by w.jezyk
ORDER BY 2 desc;

--3. Ile % procent klientów podróżowało w celach biznesowych a ilu w celach prywatnych?
SELECT w.typ_podrozy, COUNT(*) / sum(count(*)) over() * 100 as procent
from wnioski w
WHERE w.typ_podrozy is not null
group by w.typ_podrozy
ORDER BY 2 desc;

--4. Jak procentowo rozkładają się źródła polecenia?
SELECT w.zrodlo_polecenia, COUNT(*) / sum(count(*)) over() * 100 as procent
FROM wnioski w
WHERE w.zrodlo_polecenia is not null
group by w.zrodlo_polecenia
ORDER BY 2 desc;

--5. Ile podróży to trasy złożone z jednego / dwóch / trzech / więcej tras? TODO
SELECT DISTINCT sum(case when count(1) > 1 then 1 end) over()
from szczegoly_podrozy s
join podroze p ON s.id_podrozy = p.id
GROUP BY p.id
HAVING COUNT(1) > 1;

--6. Na które konto otrzymaliśmy najwięcej / najmniej rekompensaty?
SELECT konto, sum(kwota) from szczegoly_rekompensat GROUP BY konto;

--7. Który dzień jest rekordowym w firmie w kwestii utworzonych wniosków?
SELECT to_char(w.data_utworzenia, 'YYYY-MM-DD') utowrzenie, count(1)
FROM wnioski w
GROUP BY 1
order by 2 desc;

--8. Który dzień jest rekordowym w firmie w kwestii otrzymanych rekompensat?
select to_char(data_utworzenia, 'YYYY-MM-DD') utowrzenie, sum(kwota) as laczna_kwota
from szczegoly_rekompensat
GROUP BY 1
order by 2 desc;

--9. Jaka jest dystrubucja tygodniowa wniosków według kanałów? (liczba wniosków w danym tygodniu w każdym kanale)
SELECT DISTINCT to_char(data_utworzenia, 'YYYY-WW'), kanal, count(kanal) over(PARTITION BY kanal, to_char(data_utworzenia, 'YYYY-WW')) utowrzenie
from wnioski
ORDER BY  1 desc;

--10. Lista wniosków przeterminowanych (przeterminowany = utworzony w naszej firmie powyżej 3 lat od daty podróży)
SELECT DATE_PART('day', w.data_utworzenia::timestamp - s2.data_wyjazdu::timestamp) as ilosc_dni, w.*, s2.*
FROM wnioski w
JOIN podroze p ON w.id = p.id_wniosku
JOIN szczegoly_podrozy s2 ON p.id = s2.id_podrozy
WHERE DATE_PART('day', w.data_utworzenia::timestamp - s2.data_wyjazdu::timestamp) > 1095;

--Firmie zależy na tym, aby klienci do nas wracali.
--11. Jaka część naszych klientów to powracające osoby?
with powracajacy as (SELECT COUNT(1) as liczba_wnioskow
FROM klienci k
GROUP BY k.email
ORDER BY 1 DESC)

SELECT COUNT(1) / (SELECT COUNT(1) from powracajacy where liczba_wnioskow = 1)::NUMERIC as procent_powracajacych
from powracajacy
where liczba_wnioskow > 1;

--12. Jaka część naszych współpasażerów to osoby, które już wcześniej pojawiły się na jakimś wniosku?
with klient_wspolpasazer as (SELECT w.id, w.data_utworzenia as wn_data, k.imie as k_imie,
                               k.nazwisko as k_nazwisko, k.email as email, w2.imie,
                               w2.nazwisko, w2.email as wsp_email, w2.data_utworzenia wsp_data
from wnioski w
JOIN klienci k ON w.id = k.id_wniosku
JOIN wspolpasazerowie w2 ON w.id = w2.id_wniosku
ORDER BY w.id ),

wczesniejsi_klienci as (SELECT DISTINCT k_imie, k_nazwisko, email
from klient_wspolpasazer
where email = wsp_email and wn_data < wsp_data)

select count(*) / (SELECT count(*) from wspolpasazerowie)::NUMERIC from wczesniejsi_klienci;


--13. Jaka część klientów pojawiła się na innych wnioskach jako współpasażer?
with klient_wspolpasazer as (SELECT w.id, w.data_utworzenia as wn_data, k.imie as k_imie,
                               k.nazwisko as k_nazwisko, k.email as email, w2.imie,
                               w2.nazwisko, w2.email as wsp_email, w2.data_utworzenia wsp_data
from wnioski w
JOIN klienci k ON w.id = k.id_wniosku
JOIN wspolpasazerowie w2 ON w.id = w2.id_wniosku
ORDER BY w.id ),

klient_jako_wspolpasazer as (SELECT DISTINCT k_imie, k_nazwisko, email
from klient_wspolpasazer
where email = wsp_email)

select count(*) / (SELECT count(*) from klienci)::NUMERIC from klient_jako_wspolpasazer;

--14. Czy jako nowy klient mający kilka zakłóceń, od razu składasz kilka wniosków?
-- Jaki jest czas od złożenia pierwszego do kolejnego wniosku?




