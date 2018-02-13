Drop TABLE Wyniki;
DROP TABLE Lek;

CREATE TABLE Lek
(
  id SERIAL PRIMARY KEY ,
  nazwa CHARACTER VARYING(30),
  dawka NUMERIC,
  rodzaj CHARACTER VARYING(30),
  substancjaAktywna CHARACTER VARYING(30),
  producent CHARACTER VARYING(30),
  cena NUMERIC
);

CREATE CREATE TABLE Wyniki (
  id SERIAL PRIMARY KEY,
  krew NUMERIC,
  mocz NUMERIC,
  TK INTEGER,
  MRI INTEGER,
  RTG INTEGER,
  EKG BOOLEAN,
  cisnienie NUMERIC,
  dataSkierowania DATE,
  dataBadania DATE,
  dataOceny DATE,
  efekt BOOLEAN,
  id_leku INTEGER,
  id_choroby INTEGER,
  id_oddzialu INTEGER,
  id_pacjenta INTEGER,
  id_lekarza INTEGER,
  FOREIGN KEY (id_leku) REFERENCES Lek
);

