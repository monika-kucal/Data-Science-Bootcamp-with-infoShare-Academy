create table pacjent (
  ID serial Primary key,
  Grupa_krwi CHARACTER VARYING(10),
  Data_smierci DATE,
  Waga NUMERIC,
  Wzrost NUMERIC);

create table wyniki(
  ID serial primary key,
  Krew NUMERIC,
  Mocz NUMERIC,
  TK INTEGER,
  MRI INTEGER,
  RTG INTEGER,
  EKG BOOLEAN,
  Cisnienie NUMERIC,
  Data_skierowania DATE,
  Data_wykonania_badania DATE,
  Data_oceny DATE,
  Efekt BOOLEAN,
  ID_Pacjenta INTEGER,
  ID_Lekarza INTEGER,
  ID_Odzialu INTEGER,
  ID_Choroby INTEGER,
  ID_Leku INTEGER,
  foreign key(id_pacjenta) references pacjent);

  INSERT into pacjent(Grupa_krwi, Data_smierci, Waga, Wzrost)
  values ('Arh+',null,120,180);
  values ('AB',null,80,179);
  values ('OB',null,70,170);
  values ('OB','2018,01,12,',130,168);
  values ('AB',null,78,176);
  values ('BRH-',null,60,190);

  INSERT into wyniki(Krew,Mocz,TK,MRI,RTG,EKG,Cisnienie,Data_skierowania,Data_wykonania_badania,
                     Data_oceny,Efekt,ID_Pacjenta,ID_Lekarza,ID_Odzialu,ID_Choroby,ID_Leku)
  values (4.4,5.5,50,5,0.3,TRUE ,110,'2017.12.01','2017.12.14','2017.12.27',TRUE ,1,10,1000,10000,100000);
  values (4.8,5.9,70,5,0.7,TRUE ,120,'2017.12.01','2017.12.10','2017.12.23',TRUE ,2,10,1000,10001,100001);
  values (4.7,5.7,60,6,0.5,TRUE ,113,'2017.12.03','2017.12.17','2017.12.29',TRUE ,3,20,1001,10001,100002);
  values (5.4,7.5,90,9,1.3,FALSE ,130,'2017.12.09','2017.12.10','2017.12.30',FALSE ,4,10,1000,10001,100000);
  values (6.7,0,50,5,0.3,TRUE ,110,'2017.12.01','2017.12.27',NULL ,FALSE ,5,10,1000,10000,100000);
  values (4.6,5.5,0,0 ,0,TRUE ,110,'2017.12.06','2017.12.19',NULL ,FALSE ,6,10,1000,10000,100000);

 --1) lista pacjentów i średni czas od skierowania do wykonania badania

SELECT AVG((w.Data_wykonania_badania) - (w.Data_skierowania)) as sredni_czas_od_wykonania_badania
FROM wyniki w;

 --2) liczba pacjentów bez żadnych wyników

SELECT count(w.ID_Pacjenta)
FROM Wyniki w
WHERE w.cisnienie = 0 OR w.ekg = null OR w.mri = 0 OR w.mocz = 0 OR w.tk = 0
  OR w.krew = 0 OR w.rtg = 0;

 --3) liczba pacjentow z wynikami krwi odstającymi o 20% od średniej całej grupy

SELECT count(w.ID_Pacjenta)
FROM Wyniki w
WHERE w.Krew >= (SELECT AVG(Krew) FROM Wyniki) * 1.2
       OR w.Krew <= (SELECT AVG(Krew) FROM Wyniki) * 0.8;

 --4) średnie wyniki krwi , moczu w zależności od id lekarza

SELECT w.id_lekarza, AVG(Krew) as srednia_krew, AVG(Mocz) as srednia_mocz
FROM Wyniki w
GROUP BY w.id_lekarza;