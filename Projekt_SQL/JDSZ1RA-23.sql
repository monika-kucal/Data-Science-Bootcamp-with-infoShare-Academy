/*
JDSZ1RA-23
Monika Kucal
Leady bliskie przeterminowania
Wniosek jest zasadny jedynie przez 3 lata od daty trasy.
Przygotuj listę leadów, które nie zostały jeszcze wysłane (mail do klienta), ale niedługo (120 dni) kończy się ich termin ważności
 */

with max_termin AS
(select d.id id_lead, d.partner, d.id_trasy, d.jezyk, d.kraj,
   to_date(split_part(d.id_trasy,'-',3),'yyyymmdd') data_wyjazdu,
      (to_date(split_part(d.id_trasy,'-',3),'yyyymmdd') + interval'3 years')::date max_termin
from m_dane_od_partnerow d),

leady_nieobjete_kampania as
(select l.id id_lead, l.id_wniosku, l.data_wysylki, lk.id_kampania
from m_lead l
left join m_lead_kampania lk on l.id = lk.id_lead
where lk.id_kampania is null),

leady_objete_kampania_niewyslana as
(select l.id id_lead, l.id_wniosku, l.data_wysylki, lk.id_kampania, k.status
from m_lead l
join m_lead_kampania lk on l.id = lk.id_lead
  join m_kampanie k ON lk.id_kampania = k.id
where k.status in ('oczekuje','nowa'))
/*
select wd.id_lead,
  wd.partner,
  wd.jezyk,
  wd.kraj,
  wd.data_wyjazdu,
  coalesce(ln.id_kampania,lokn.id_kampania) id_kampania,
  coalesce(ln.id_lead,lokn.id_lead) id_lead,
  wd.id_lead,
  wd.max_termin,
  extract (days from wd.max_termin-now()) ile_dni_do_przeterminowania,
  lokn.status
from max_termin wd
left join leady_nieobjete_kampania ln on (wd.id_lead=ln.id_lead)
left join leady_objete_kampania_niewyslana lokn on (wd.id_lead=lokn.id_lead)
where coalesce(ln.id_lead,lokn.id_lead) is not null
--and wd.max_termin>now()::timestamp
and extract (days from wd.max_termin-now()::timestamp) <120
order by 6*/

--do Tableau
select wd.id_lead,
  wd.partner,
  wd.jezyk,
  wd.kraj,
  wd.data_wyjazdu,
  coalesce(ln.id_kampania,lokn.id_kampania) id_kampania,
  coalesce(ln.id_lead,lokn.id_lead) id_lead,
  wd.id_lead,
  wd.max_termin,
  extract (days from wd.max_termin-now()) ile_dni_do_przeterminowania,
  lokn.status
from max_termin wd
left join leady_nieobjete_kampania ln on (wd.id_lead=ln.id_lead)
left join leady_objete_kampania_niewyslana lokn on (wd.id_lead=lokn.id_lead)
where coalesce(ln.id_lead,lokn.id_lead) is not null
--and wd.max_termin>now()::timestamp
and extract (days from wd.max_termin-now()::timestamp) <120
order by 6;