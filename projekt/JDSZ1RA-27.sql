Filip Jakubowski

Ile emaili wysyłamy w dniu / miesiącu / kwartale / roku?
jakie są łączne koszty wysyłki maili, jeśli wysłanie jednego emaila kosztuje 10groszy?
czy są partnerzy, dla których nie opłaca nam sie wysyłać emaili (ponieważ bardzo mało spraw zostało wygranych)?


WITH moje_dane AS (
SELECT
  TO_char(k.data_kampanii, 'YYYY-MM-DD') data_wyslania,
  e.id,
  dop.partner,
  e.ile_otwarto otwarto,
  e.ile_kliknieto klik,
  w.kwota_rekompensaty_oryginalna kwota,
  w.stan_wniosku stan_wniosku
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

mail_partner_dzien AS (
SELECT
  data_wyslania,
  partner,
  COUNT(1) n_mail
FROM moje_dane
GROUP BY 1, 2),

zarobione AS (
SELECT
  data_wyslania,
  partner,
  0.25*SUM(kwota) zarobek
FROM moje_dane
WHERE stan_wniosku = 'wyplacony'
GROUP BY 1, 2
ORDER BY 1)

SELECT
  mpd.data_wyslania,
  mpd.partner,
  mpd.n_mail,
  zar.zarobek,
  mpd.n_mail*0.1 koszt
FROM mail_partner_dzien mpd
JOIN zarobione zar ON zar.data_wyslania = mpd.data_wyslania AND zar.partner = mpd.partner;
