with konwersja as
  (select distinct l.id_wniosku,l.id id_lead,
     last_value(k.id) over (partition by l.id_wniosku) id_skutecznej_kampanii,
      m2.jezyk as jezyk
  from m_lead l
  join m_lead_kampania lk ON l.id = lk.id_lead
  join m_kampanie k ON lk.id_kampania = k.id
  join m_dane_od_partnerow m2 ON l.id = m2.id
     where k.status='wyslane'
  and l.id_wniosku is not null),

konwersja_agr AS
  (select id_skutecznej_kampanii, jezyk, count(id_wniosku) convert
      from konwersja
        group by 1,2),

mianownik as
  (select distinct k.id id_kampanii,
    lk.id_lead id_lead,
    mdop.jezyk jezyk
from m_lead l
join m_lead_kampania lk on l.id=lk.id_lead
join m_kampanie k ON lk.id_kampania = k.id
join m_dane_od_partnerow mdop ON l.id = mdop.id),

  mianownik_agr AS
  (select id_kampanii, jezyk, count(id_lead) sent
      from mianownik
        group by 1,2),

summary as
  (select m.id_kampanii, m.jezyk, coalesce(k.convert, 0) convert, coalesce(m.sent, 0) sent
from mianownik_agr m
left join konwersja_agr k on (m.id_kampanii=k.id_skutecznej_kampanii) and m.jezyk = k.jezyk),

base as (select jezyk,
  sum(convert) pozytywne, sum(sent) - sum(convert) negatywne , sum(sent) wszystkie,
    sum(convert) / sum(sum(convert)) over() as DG,
    (sum(sent) - sum(convert)) / sum((sum(sent) - sum(convert))) over() as DB
from summary
  group by 1
order by 1),

WoE as (select jezyk as jWoE, ln(DG/DB) WoE_val from base),

DG_DB_diff as (select jezyk as jDiff, (DG - DB) DDiff from base),

IV_Part as (select DDiff * WoE_val as IV from DG_DB_diff join WoE on jDiff = jWoE)

select sum(IV) from IV_Part

