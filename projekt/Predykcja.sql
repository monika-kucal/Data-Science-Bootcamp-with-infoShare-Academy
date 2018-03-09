with daty as (select
generate_series(
date_trunc('month', now()-interval '2 month'),
date_trunc('month', now())+interval '1 month'-interval '1 day',
'1 day')::date as wygenerowana_data
),
  leady as (
select to_char(data_wysylki, 'YYYY-MM-DD')::date data_leada, count(1) liczba_leadow
from m_lead
group by 1
),
  emaile as (
    select to_char(data_wysylki, 'YYYY-MM-DD')::date data_emaila, count(1) liczba_emaili
from m_email
left join m_lead m2 ON m_email.lead_id = m2.id
group by 1
  ),
  statystyki_lead as (
    select to_char(data_leada, 'Day') dzien, round(avg(liczba_leadow)) przew_liczba_leadow
    from leady
      where data_leada <= '2018-02-17'
    group by 1
    order by 1
  ),
  statystyki_emaile as (
    select to_char(data_emaila, 'Day') dzien, round(avg(liczba_emaili)) przew_liczba_emaili
    from emaile
      where data_emaila <= '2018-02-17'
    group by 1
    order by 1
  )

select d.wygenerowana_data, coalesce(l.liczba_leadow, 0) as liczba_leadow, coalesce(e.liczba_emaili, 0) as liczba_emaili,
  case
    when wygenerowana_data <= '2018-02-17' then l.liczba_leadow
    else sl.przew_liczba_leadow end finalna_liczba_leadow,
  case
    when wygenerowana_data <= '2018-02-17' then e.liczba_emaili
    else se.przew_liczba_emaili end finalna_liczba_emaili,
  sum(case
    when wygenerowana_data <= '2018-02-17' then l.liczba_leadow
    else sl.przew_liczba_leadow end) over(order by wygenerowana_data) leady_skumulowane,
  sum(case
    when wygenerowana_data <= '2018-02-17' then e.liczba_emaili
    else se.przew_liczba_emaili end) over(order by wygenerowana_data) emaile_skumulowane
from daty d
left join leady l on d.wygenerowana_data = l.data_leada
left join emaile e on d.wygenerowana_data = e.data_emaila
left join statystyki_lead sl on sl.dzien = to_char(d.wygenerowana_data, 'Day')
left join statystyki_emaile se on se.dzien = to_char(d.wygenerowana_data, 'Day')
