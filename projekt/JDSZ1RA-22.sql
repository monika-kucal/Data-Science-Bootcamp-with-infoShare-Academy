-- Ile leadów tworzonych jest każdego dnia dla każdego partnera?
/*
-- EKSPLORACJA DANYCH
-- Ilu mam partnerów? 5 partnerów
SELECT DISTINCT partner
FROM m_dane_od_partnerow;

-- Jaki jest zakres dat dla leadów? Od 2015-10-26 13:06:52.907009, do 2998-01-01 00:00:00.000000
SELECT
  MIN(data_wysylki),
  MAX(data_wysylki)
FROM m_lead;

-- Skąd ta dziwna data? 17232 leadów z przyszłości. PR: To mogą być leady na zaplanowane kampanie.
SELECT count(1)
FROM m_lead
WHERE data_wysylki > now();

-- Nie każda dana od partnerów ma datę wysyłki leada. Na 780397 danych od partnerów, 146065 ma datę wysylki leada , a 634332 jej nie ma.
SELECT count(1)
FROM m_dane_od_partnerow dp
LEFT JOIN m_lead l ON dp.id = l.id
WHERE l.data_wysylki IS NULL;


-- Data wysyłki leada jest najczęściej poźniejsza od daty kampanii,...
SELECT COUNT(DISTINCT l.id)
FROM m_lead l
JOIN m_lead_kampania lk ON l.id = lk.id_lead
JOIN m_kampanie k ON lk.id_kampania = k.id
WHERE k.data_kampanii < l.data_wysylki
ORDER BY 1;

-- ...a data utworzenia wniosku jest najczęściej wcześniejsza od daty utworzenia leada.
SELECT COUNT(1)
FROM m_lead l
JOIN wnioski w ON l.id_wniosku = w.id
WHERE l.data_wysylki < w.data_utworzenia;
*/

-- ODPOWIEDŹ
-- Założenie: data wysyłki leada jest datą jego utworzenia,
WITH leady AS (SELECT
  TO_CHAR(l.data_wysylki, 'YYYY-MM-DD') data_utw_lead,
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
GROUP BY 1, 2)

SELECT
  partner,
  AVG(n_lead),
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY n_lead),
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY n_lead),
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY n_lead)
FROM leady
GROUP BY partner;

