/*
JDSZ1RA-23
Monika Kucal
Leady bliskie przeterminowania
Wniosek jest zasadny jedynie przez 3 lata od daty trasy.
Przygotuj listę leadów, które nie zostały jeszcze wysłane (mail do klienta), ale niedługo (120 dni) kończy się ich termin ważności
 */

with wnioski_max_termin as
(select w.id, w.data_utworzenia::date data_utworzenia, s2.data_wyjazdu, (s2.data_wyjazdu + interval'3 years')::date max_termin
from wnioski w
join podroze p ON w.id = p.id_wniosku
join szczegoly_podrozy s2 ON p.id = s2.id_podrozy
where s2.czy_zaklocony=true),

leady_nieobjete_kampania as
(select l.*, lk.id_kampania
from m_lead l
left join m_lead_kampania lk on l.id = lk.id_lead
where lk.id_kampania is null),

leady_objete_kampania_niewyslana as
(select l.*, lk.id_kampania, k.status
from m_lead l
join m_lead_kampania lk on l.id = lk.id_lead
  join m_kampanie k ON lk.id_kampania = k.id
where k.status in ('oczekuje','nowa'))
/*
select coalesce(ln.id_kampania,lokn.id_kampania) id_kampania,
  coalesce(ln.id,lokn.id) id_lead,
  wd.id id_wniosku,
  wd.data_utworzenia,
  wd.data_wyjazdu,
  wd.max_termin,
  extract (days from wd.max_termin-now()) ile_dni_do_przeterminowania,
  lokn.status
from wnioski_max_termin wd
left join leady_nieobjete_kampania ln on (wd.id=ln.id_wniosku)
left join leady_objete_kampania_niewyslana lokn on (wd.id=lokn.id_wniosku)
where coalesce(ln.id,lokn.id) is not null
and wd.max_termin>now()::timestamp
and extract (days from wd.max_termin-now()::timestamp) <120
order by 6;*/

--do Tableau
select coalesce(ln.id_kampania,lokn.id_kampania) id_kampania,
  coalesce(ln.id,lokn.id) id_lead,
  wd.id id_wniosku,
  wd.data_utworzenia,
  wd.data_wyjazdu,
  wd.max_termin,
  extract (days from wd.max_termin-now()) ile_dni_do_przeterminowania,
  lokn.status
from wnioski_max_termin wd
left join leady_nieobjete_kampania ln on (wd.id=ln.id_wniosku)
left join leady_objete_kampania_niewyslana lokn on (wd.id=lokn.id_wniosku)
where coalesce(ln.id,lokn.id) is not null
--and wd.max_termin>now()::timestamp
and extract (days from wd.max_termin-now()::timestamp) <120
order by 6;