/*
JDSZ1RA-24/25/26
Monika Kucal

Jaki jest open rate w zależności od daty wysłania leada?
Jaki jest click rate w zależności od daty wysłania leada?
Jaki jest conversion rate (lead --> wniosek) w zależności od daty wysłania leada?

(IMPAKT + ttest) Open + click rate + konwersja (czy open/click/konwersja znacząco różni się w zależności od dnia wysyłki?)
*/

with open_click as
(select
  k.id id_kampanii,
  k.data_kampanii,
  e.id id_email,
  case when e.ile_otwarto>0 then 1 end czy_otwarto,
  case when e.ile_kliknieto>0 then 1 end czy_kliknieto
from m_email e
join m_kampanie k ON e.id_kampanii = k.id
where k.status='wyslane'),

 open_click_agr as
  (select id_kampanii,
  count(czy_otwarto) open,
  count(czy_kliknieto) click,
  count(*) sent
from open_click
group by 1),

konwersja as
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
  (select m.id_kampanii, m.typ_kampanii, m.data_kampanii, oc.open, oc.click, k.convert, m.sent
from mianownik_agr m
left join open_click_agr oc on m.id_kampanii=oc.id_kampanii
left join konwersja_agr k on m.id_kampanii=k.id_skutecznej_kampanii)

--do testu t konwersja
  select m.id_kampanii,
  to_char(m.data_kampanii,'YYYY-Q') data_wyslania,
    case when m.id_kampanii=k.id_skutecznej_kampanii then 1 else 0 end convert
  from mianownik m
  left join konwersja k on m.id_lead=k.id_lead
where m.data_kampanii between '2016-01-01' and '2017-12-31';

--do testu t open+click
  select id_email, to_char(data_kampanii,'YYYY-Q') data_wyslania,
    coalesce(czy_otwarto,0) open,
    coalesce(czy_kliknieto,0) click
  from open_click
  where data_kampanii between '2016-01-01' and '2017-12-31';

--do Tableau
select *
from summary
  where to_char(data_kampanii,'YYYY-MM-DD') between '2016-01-01' and '2017-12-31'
order by 1;

--wskaźniki
select to_char(data_kampanii,'YYYY-Q') data_kampanii,
  sum(open)/sum(sent) open_rate,
  sum(click)/sum(sent) click_rate,
  sum(convert)/sum(sent) convert_rate
from summary
  where data_kampanii between '2016-01-01' and '2017-12-31'
  group by 1
order by 1;
