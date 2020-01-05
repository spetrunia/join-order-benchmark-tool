drop table if exists my_job_result;

create table my_job_result(
  query_name varchar(64),
  query_start datetime,
  query_time_ms bigint
);

