
# Query for confirmed cases and recovered cases

DROP TABLE IF EXISTS COVID19_country_daywise;

CREATE TABLE IF NOT EXISTS COVID19_country_daywise
as
select trim(country_region) as country, str_to_date(date_reported, '%m-%d-%Y') as date_reported,
ifnull(sum(confirmed),0) as cum_confirmed,
ifnull(sum(recovered),0) as cum_recovered from covid_19_daily_reports
where 1=1
and country_region is not null
group by country_region, str_to_date(date_reported, '%m-%d-%Y');

select * from COVID19_country_daywise;

CREATE TABLE IF NOT EXISTS COVID19_country_daywise_seq
as
select trim(a.country) as country, a.date_reported, a.cum_confirmed, a.cum_recovered, count(*) country_seq
from COVID19_country_daywise a, COVID19_country_daywise b
where a.country = b.country
and a.date_reported >= b.date_reported
group by a.country, a.date_reported,a.cum_confirmed,a.cum_recovered;

select * from COVID19_country_daywise_seq;

CREATE TABLE IF NOT EXISTS COVID19_country_daywise_summary
as
select a.*, (a.cum_confirmed - ifnull(b.cum_confirmed,0)) as new_confirmed,
(a.cum_recovered - ifnull(b.cum_recovered,0)) as new_recovered
from COVID19_country_daywise_seq a
left outer join COVID19_country_daywise_seq b
ON a.country = b.country
and a.country_seq = b.country_seq+1
order by 1,2,4;

select * from COVID19_country_daywise_summary;