CREATE TABLE Choroba (
  ID SERIAL PRIMARY KEY,
  Nazwa CHARACTER VARYING(30),
  Rodzaj CHARACTER VARYING(30),
  Specjalizacja CHARACTER VARYING(30)
);

CREATE TABLE Wynik (
  ID SERIAL PRIMARY KEY,
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
  Efekty BOOLEAN,
  ID_Pacjenta INTEGER,
  ID_Lekarza INTEGER,
  ID_Oddzialu INTEGER,
  ID_Choroby INTEGER,
  FOREIGN KEY (ID_Choroby) REFERENCES Choroba
);

INSERT INTO Choroba (Nazwa, Rodzaj, Specjalizacja) VALUES
  ('Grypa', 'Wirusowa', 'Zakazna'),
  ('Zoltaczka', 'Wirusowa', 'Zakazna'),
  ('Cholera', 'Bakteryjna', 'Zakazna'),
  ('Bialaczka', 'Genetyczna', 'Onkologiczna');

INSERT INTO Wynik
  (Krew, Mocz, TK, MRI, RTG, EKG, Cisnienie, Data_skierowania, Data_wykonania_badania, Data_oceny, Efekty, ID_Pacjenta, ID_Lekarza, ID_Oddzialu, ID_Choroby)
VALUES
  (10.8, 5.1, 2, 3, 5, TRUE, 88, '2017-01-05', '2017-01-06', '2017-01-08', FALSE, 114627, 254861, 21544, 1),
  (5.4, 17.3, 5, 6, 8, FALSE, 100, '2017-02-01', '2017-02-01', '2017-02-08', TRUE, 154247, 254124, 21546, 4);

-- Lista chorob upozadkowana malejaco wedlug wynkow krwi
SELECT ID_Choroby, Krew
FROM Wynik
ORDER BY Krew DESC;


-- Wybor nazwy choroby i zliczenie ilosci wystepowania
SELECT ID_Choroby, COUNT(*)
FROM Wynik
GROUP BY ID_Choroby;

-- Wybrano RTG, poniewaz EKG jest boolean
SELECT ID_Choroby, MAX(RTG) AS RTG_MAX, MIN(RTG) AS RTG_MIN
FROM Wynik
GROUP BY ID_Choroby;

-- Sprawdzenie wynikow RTG odstajacych dwukrotnie od normy
SELECT ID
FROM Wynik
WHERE
RTG > (SELECT 1.5*AVG(RTG)
         FROM Wynik)
OR
RTG < (SELECT 0.5*AVG(RTG)
         FROM Wynik);



