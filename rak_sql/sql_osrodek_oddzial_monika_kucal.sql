/*
Monika Kucal
Praca domowa - SQL Raczki
Tabele osrodek, oddzial: create, insert, select
 */

--I. DDL

--1) Tworzenie tabeli osrodek
create table osrodek(
id serial primary key,
miasto character varying(30) not null,
jednostka character varying(100) not null);

--2) Tworzenie tabeli oddzial
create table oddzial(
id serial primary key,
nazwa_oddzialu character varying(30),
id_osrodka integer not null,
foreign key (id_osrodka) references osrodek);


--II. REKORDY

--Kilka przykładowych rekordów do tabeli osrodek
insert into osrodek(miasto, jednostka) values('Gdańsk','Szpital Wojewódzki');
insert into osrodek(miasto, jednostka) values('Gdynia','Szpital Miejski');
insert into osrodek(miasto, jednostka) values('Tczew','Szpital Powiatowy');
insert into osrodek(miasto, jednostka) values('Sopot','Szpital Miejski');

--Kilka przykładowych rekordów do tabeli oddzial
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Chirurgia', 1);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Kardiochirurgia', 1);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Onkologia', 2);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Kardiochirurgia', 2);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Hematologia', 2);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Kardiochirurgia', 4);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Chirurgia', 4);
insert into oddzial(nazwa_oddzialu, id_osrodka) values('Onkologia', 4);

select * from oddzial;
select * from osrodek;

--III. ZAPYTANIA

--Zapytanie 1) liczba oddziałów w ośrodkach
select a.miasto, a.jednostka, count(b.*) as liczba_oddzialow
from osrodek a
left join oddzial b on (a.id=b.id_osrodka)
group by a.miasto, a.jednostka;

--Zapytanie 2) lista ośrodków bez żadnego oddzialu
select a.miasto, a.jednostka
from osrodek a
left join oddzial b on (a.id=b.id_osrodka)
group by a.miasto, a.jednostka
having count(b.*)=0;

--Zapytanie 3) lista ośrodków z miast rozpoczynających się na 'G' albo posiadających 'an' w środku albo mających więcej niż dwa oddziały (jedno zapytanie)
select a.miasto, a.jednostka
from osrodek a
left join oddzial b on (a.id=b.id_osrodka)
group by a.miasto, a.jednostka
having a.miasto like 'G%' or a.miasto like '%an%' or count(b.*)>2;

--Zapytanie 4) oddziały w ośrodkach
select a.miasto, a.jednostka, array_to_string(array_agg(b.nazwa_oddzialu),', ') as oddzialy
from osrodek a
left join oddzial b on (a.id=b.id_osrodka)
group by a.miasto, a.jednostka
order by 1