with konwersja as
  (select distinct l.id_wniosku,l.id id_lead,
     last_value(k.id) over (partition by l.id_wniosku) id_skutecznej_kampanii
   from m_lead l
  join m_lead_kampania lk ON l.id = lk.id_lead
  join m_kampanie k ON lk.id_kampania = k.id
     where k.status='wyslane'
  and l.id_wniosku is not null),

konwersja_agr AS
  (select id_skutecznej_kampanii, count(id_wniosku) convert
      from konwersja
        group by 1),

mianownik as
  (select k.id id_kampanii,
    k.typ_kampanii,
   k.data_kampanii ,
    lk.id_lead id_lead,
     k.status
from m_lead l
join m_lead_kampania lk on l.id=lk.id_lead
join m_kampanie k ON lk.id_kampania = k.id),

  mianownik_agr AS
  (select id_kampanii, typ_kampanii, data_kampanii, count(id_lead) sent
      from mianownik
        group by 1,2,3),

summary as
  (select m.id_kampanii, m.typ_kampanii, m.data_kampanii, k.convert, m.sent
from mianownik_agr m
left join konwersja_agr k on m.id_kampanii=k.id_skutecznej_kampanii),

base as (select to_char(data_kampanii,'MM') data_kampanii,
  sum(convert) pozytywne, sum(sent) - sum(convert) negatywne , sum(sent) wszystkie,
    sum(convert) / sum(sum(convert)) over() as DG,
    (sum(sent) - sum(convert)) / sum((sum(sent) - sum(convert))) over() as DB
from summary
  group by 1
    order by 1
  ),

WoE as (select data_kampanii as dkWoE, ln(DG/DB) WoE_val from base),

DG_DB_diff as (select data_kampanii as dkDiff, (DG - DB) DDiff from base),

IV_Part as (select dkDiff as data_kampanii, DDiff * WoE_val as IV from DG_DB_diff join WoE on dkDiff = dkWoE)

--select sum(IV) from IV_Part

select b.*, w.WoE_val, d.DDiff, i.IV from base b
join WoE w on b.data_kampanii = w.dkWoE
join DG_DB_diff d on b.data_kampanii = d.dkDiff
join IV_Part i on b.data_kampanii = i.data_kampanii
