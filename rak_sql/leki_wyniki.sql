
INSERT INTO Lek (nazwa, dawka, rodzaj, substancjaAktywna, producent, cena) VALUES
  ('Rutinoscorbin', 30.0, 'tabletki', 'kwas askorbinowy', 'Polpharma', 7.99);
INSERT INTO Lek (nazwa, dawka, rodzaj, substancjaAktywna, producent, cena) VALUES
  ('Polopiryna', 50.0, 'tabletki', 'kwas acetylosalicylowy', 'Polpharma', 10.99);

INSERT INTO Wyniki (krew, mocz, TK, MRI, RTG, EKG,
                    cisnienie, dataSkierowania, dataBadania, dataOceny, efekt, id_leku,
                    id_choroby, id_oddzialu, id_pacjenta, id_lekarza)
VALUES (12.0, 9.0, 3, 4, 5, false, 180.0,
                        current_date, current_date, current_date, false, 1, 4, 5, 1, 2);
INSERT INTO Wyniki (krew, mocz, TK, MRI, RTG, EKG,
                    cisnienie, dataSkierowania, dataBadania, dataOceny, efekt, id_leku,
                    id_choroby, id_oddzialu, id_pacjenta, id_lekarza)
VALUES (3.0, 9.0, 3, 5, 5, true, 130.0,
                        current_date, current_date, current_date, false, 2, 5, 5, 2, 1);

SELECT w.*, l.* from Wyniki w LEFT JOIN Lek l ON l.id =  w.id_leku;
