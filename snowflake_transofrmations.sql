create schema weather_project.bronze;
create schema weather_project.silver;
create schema weather_project.gold;

use schema weather_project.bronze;


///bronze layer
create or replace file format weather
type = json;


create storage integration azure_weather_int
type = external_stage
storage_provider = 'AZURE'
ENABLED = TRUE
AZURE_TENANT_ID = '29e387d0-69ec-4218-9856-1a723fea626f'
STORAGE_ALLOWED_LOCATIONS = ('azure://weatherdataforcardiff032.blob.core.windows.net/cardiffdata/');

DESC STORAGE INTEGRATION azure_weather_int;

create or replace stage weather_stage
url = 'azure://weatherdataforcardiff032.blob.core.windows.net/cardiffdata'
STORAGE_INTEGRATION = azure_weather_int
file_format = weather;

create or replace table bronze_weather(
raw variant

);

copy into bronze_weather
from @weather_stage
file_format = weather;

// silver layer

use schema weather_project.silver;

select object_keys(raw:hourly)
from weather_project.bronze.bronze_weather;

create or replace table weather_project.silver.silver_weather as 
select
f.value::timestamp as forecast_time,
raw:hourly:temperature_2m[f.index]::int as temp_C,
raw:hourly:precipitation[f.index]::int as precipitation,
raw:hourly:weather_code[f.index]::int as weather_code,
from weather_project.bronze.bronze_weather,
lateral flatten (input => raw:hourly:time) as f;

select * from silver_weather
limit 10;


//gold layer


use schema gold;

create or replace table gold.weather_gold
as select 
date(forecast_time) as forecast_date,
hour(forecast_time) as forecast_hour,
temp_c,
precipitation
from weather_project.silver.silver_weather
;


create or replace view gold.avg_daily_temp as(
select
    forecast_date,
    avg(temp_c) as avg_temp
from weather_gold 
group by 1);


create or replace view total_daily_rain as (
select forecast_date,
sum(precipitation) as total_rain,
from weather_gold
group by 1);


create or replace view bad_weather_days as(
select forecast_date,
max(temp_c) as max_temp,
min(temp_c) as min_temp,
sum(precipitation) as total_rain,
case
when min(temp_c)<=0 and sum(precipitation) >0 then 'Risk of snow'
when sum(precipitation) > 10 then 'heavy rain warning'
else 'normal'
end as weather_status
from weather_gold
group by 1);

create or replace view daily_high_low as(
select
forecast_hour,
max(temp_c) as lowest_temp,
min(temp_c) as highest_temp
from weather_gold
group by 1);


create or replace view hourly_timeline as(
select
forecast_date,
forecast_hour as hour_of_day,
temp_c as tempurature,
precipitation
from weather_gold
order by forecast_date asc
);




