/*
Dla każdego partnera:

ilość leadów
% open rate
% click rate
% konwersji do wniosku
średnia wartość wniosku

Bartosz Górnikiewicz

UWAGI: dla itaki są wnioski, które były złożone bez względu na otwarcie i kliknięcie maili?
 */

-- Pobieram potrzebne dane
WITH moje_dane AS (
SELECT
  dop.partner partner,
  l.id l_id,
  l.id_wniosku w_id,
  k.data_kampanii data_kampania,
  e.id e_id,
  l.data_wysylki data_lead,
  w.data_utworzenia data_wniosek,
  e.ile_otwarto otwarto,
  e.ile_kliknieto klik,
  w.kwota_rekompensaty_oryginalna kwota
FROM m_lead l
JOIN m_lead_kampania lk ON l.id = lk.id_lead
JOIN m_kampanie k ON lk.id_kampania = k.id
JOIN m_email e ON k.id = e.id_kampanii AND e.lead_id = l.id
JOIN m_dane_od_partnerow dop ON l.id = dop.id
LEFT JOIN wnioski w ON l.id_wniosku = w.id
-- analizujemy tylko wysłane kampanie
WHERE k.status = 'wyslane'
-- oraz tylko wnioski utworzeone po lead'zie
AND (l.data_wysylki < w.data_utworzenia OR w.data_utworzenia IS NULL)
-- oraz odrzucamy leady z przyszłości
AND l.data_wysylki < NOW()
ORDER BY l.id),

-- Obliczam liczbę unikatowych leadów dla każdego z partnerów
n_lead AS (
SELECT
  partner,
  COUNT(DISTINCT l_id) n_lead,
  1 initial_rate
FROM moje_dane
GROUP BY partner),

-- sprawdzam czy każdy lead był chociaż raz otwarty lub kliknięty
lead_effect AS (
SELECT
  partner,
  l_id,
  CASE WHEN SUM(otwarto) > 0 THEN 1 ELSE 0 END open,
  CASE WHEN SUM(klik) > 0 THEN 1 ELSE 0 END klik
FROM moje_dane
GROUP BY partner, l_id),

-- obliczam rate'y czyli jaka część leadów miała chociaż jeden email otwarty lub klikniety
rates AS (
SELECT
  partner,
  SUM(open) n_open,
  ROUND(AVG(open), 4) open_rate,
  SUM(klik) n_klik,
  ROUND(AVG(klik), 4) klik_rate
FROM lead_effect
GROUP BY partner),

-- obliczam konwersję jako liczbę unikatowych wniosków przez liczbę unikatowych lead'ów
konwersja AS (
SELECT
  partner,
  COUNT(DISTINCT w_id) n_wniosek,
  ROUND(COUNT(DISTINCT w_id)/COUNT(DISTINCT l_id)::NUMERIC, 4) konwersja
FROM moje_dane
GROUP BY partner),

kwoty AS (
SELECT
  DISTINCT l_id,
  partner,
  kwota
FROM moje_dane),

avg_kwoty AS (
SELECT
  partner,
  ROUND(AVG(kwota), 2) kwota
FROM kwoty
GROUP BY partner)

-- Raport
SELECT *
FROM n_lead
JOIN rates USING (partner)
JOIN konwersja USING (partner)
JOIN avg_kwoty USING  (partner);
