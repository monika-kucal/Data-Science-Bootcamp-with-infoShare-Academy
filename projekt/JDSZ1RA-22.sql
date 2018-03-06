-- Ile leadów tworzonych jest każdego dnia dla każdego partnera?
-- Bartosz Górnikiewicz
-- Założenie: data wysyłki leada jest datą jego utworzenia,
WITH daty_graniczne AS (
SELECT
  MIN(data_wysylki) min_data,
  MAX(data_wysylki) max_data
FROM m_lead
WHERE data_wysylki < NOW()),

daty_wygenerowane AS (
SELECT
    GENERATE_SERIES(
        (SELECT min_data FROM daty_graniczne)::date,
        (SELECT max_data FROM daty_graniczne)::date,
        '1 day'
    )::date dzien),

lead_na_dzien AS (
      SELECT
        TO_CHAR(l.data_wysylki, 'YYYY-MM-DD')::date dzien,
        dop.partner partner,
        COUNT(l.id) n_lead
      FROM m_lead l
        -- dodajemy dane o partnerach dla kazdego leada
        JOIN m_dane_od_partnerow dop ON l.id = dop.id
        -- dodajemy dane o wnioskach
        LEFT JOIN wnioski w ON l.id_wniosku = w.id
      -- bierzemy tylko leady, które zostały utworzone przed wnioskami
      WHERE l.data_wysylki < w.data_utworzenia OR w.data_utworzenia IS NULL
      -- usuwamy leady utworzone w przyszłości
      AND l.data_wysylki < now()
      GROUP BY 1, 2),

daty_przystapienia AS (
SELECT
  partner,
  MIN(dzien)::date data_przystapienia
FROM lead_na_dzien
GROUP BY 1),

-- Wyciągamy liczbę leadów dal poszczególnych partnerów, aby móc przyporządkować 0 dniom bez leadów
dreamtours AS (
SELECT dzien, n_lead
FROM lead_na_dzien
WHERE partner = 'dreamtours'
  ),

dreamtours_corr AS (
SELECT
  dzien,
  'dreamtours' partner,
  COALESCE(dreamtours.n_lead, 0) n_lead
FROM daty_wygenerowane dw
LEFT JOIN dreamtours USING(dzien)
WHERE dw.dzien >= (SELECT data_przystapienia FROM daty_przystapienia WHERE partner = 'dreamtours')),

wakacje_pl AS (
SELECT dzien, n_lead
FROM lead_na_dzien
WHERE partner = 'wakacje.pl'),

wakacje_pl_corr AS (
SELECT
  dzien,
  'wakacje.pl' partner,
  COALESCE(wakacje_pl.n_lead, 0) n_lead
FROM daty_wygenerowane dw
LEFT JOIN wakacje_pl USING(dzien)
WHERE dw.dzien >= (SELECT data_przystapienia FROM daty_przystapienia WHERE partner = 'wakacje.pl')),

kiribati AS (
SELECT dzien, n_lead
FROM lead_na_dzien
WHERE partner = 'kiribati'),

kiribati_corr AS (
SELECT
  dzien,
  'kiribati' partner,
  COALESCE(kiribati.n_lead, 0) n_lead
FROM daty_wygenerowane dw
LEFT JOIN kiribati USING(dzien)
WHERE dw.dzien >= (SELECT data_przystapienia FROM daty_przystapienia WHERE partner = 'kiribati')),

tui AS (
SELECT dzien, n_lead
FROM lead_na_dzien
WHERE partner = 'tui'),

tui_corr AS (
SELECT
  dzien,
  'tui' partner,
  COALESCE(tui.n_lead, 0) n_lead
FROM daty_wygenerowane dw
LEFT JOIN tui USING(dzien)
WHERE dw.dzien >= (SELECT data_przystapienia FROM daty_przystapienia WHERE partner = 'tui')),

itaka AS (
SELECT dzien, n_lead
FROM lead_na_dzien
WHERE partner = 'itaka'),

itaka_corr AS (
SELECT
  dzien,
  'itaka' partner,
  COALESCE(itaka.n_lead, 0) n_lead
FROM daty_wygenerowane dw
LEFT JOIN itaka USING(dzien)
WHERE dw.dzien >= (SELECT data_przystapienia FROM daty_przystapienia WHERE partner = 'itaka'))

-- Następnie łączę zaytania. Uzywam UNION, a nie JOIN, bo łatwiej to później przeliczyć w Tableau.
-- Bez okeślenia formatów dla każdego z pól SQL wyrzuca błąd.

SELECT dzien::date, partner::text, n_lead::NUMERIC FROM dreamtours_corr
UNION
SELECT dzien::date, partner::text, n_lead::NUMERIC FROM wakacje_pl_corr
UNION
SELECT dzien::date, partner::text, n_lead::NUMERIC FROM kiribati_corr
UNION
SELECT dzien::date, partner::text, n_lead::NUMERIC FROM tui_corr
UNION
SELECT dzien::date, partner::text, n_lead::NUMERIC FROM itaka_corr;

