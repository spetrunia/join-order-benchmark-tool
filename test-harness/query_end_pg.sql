
-- #select sum(seq_tup_read) + sum(idx_tup_fetch) from pg_stat_xact_user_tables ;

update my_job_cur_query 
set query_rows_read = (select sum(seq_tup_read) + sum(idx_tup_fetch) from pg_stat_xact_user_tables);

insert into my_job_result
select 
  query_name, 
  query_start_time, 
  1000*extract(epoch from (clock_timestamp() - query_start_time)),
  query_rows_read
from
  my_job_cur_query;
commit;
