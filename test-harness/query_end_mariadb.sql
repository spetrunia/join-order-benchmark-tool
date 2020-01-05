
set @query_time_ms= timestampdiff(microsecond, @query_start, current_timestamp(6))/1000;
insert into my_job_result values(@query_name, @query_start, @query_time_ms);
--select concat('LOG_','END:') as header,  @query_name, @query_time_ms;
