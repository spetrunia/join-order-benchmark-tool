
begin;
delete from my_job_cur_query;
insert into my_job_cur_query values('__QUERY_NAME__', clock_timestamp());
commit;

begin;
