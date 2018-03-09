Filip Jakubowski

Ile emaili wysyłamy w dniu / miesiącu / kwartale / roku?
jakie są łączne koszty wysyłki maili, jeśli wysłanie jednego emaila kosztuje 10groszy?

select to_char(data_kampanii, 'YYYY') Rok,
      to_char(data_kampanii, 'Month') Miesiace,
      to_char(data_kampanii, 'Q') Kwartal,
      to_char(data_kampanii, 'Day') Dni,
      --count(4) ilosc_wyslanych_emaili,
      count(CASE WHEN a.status IN ('zaakceptowany') then 1 END) ilosc_wyslanych_emaili,
      --/sum(COUNT(7)) over (),5))*100 procent_zaakceptowanych,
      round(count(CASE WHEN a.status IN ('zaakceptowany') then 1 END)*0.1,2) cena_wysania_emaili, -- cena wyslania maila to 10 gr
      --count(CASE WHEN a.status IN ('zaakceptowany') then 1 END)*250*0.25 min_wartość_zysku -- minimalna rekompensata wynosi 250 i nasza prowizja to 25%
FROM m_kampanie
JOIN m_email m ON m_kampanie.id = m.id_kampanii
JOIN m_lead_kampania m2 ON m_kampanie.id = m2.id_kampania
JOIN m_lead l ON m2.id_lead = l.id
JOIN wnioski w ON l.id_wniosku = w.id
left JOIN analizy_wnioskow a ON w.id = a.id_wniosku
GROUP by 1,2,3,4
ORDER BY 1,3,2,4;
