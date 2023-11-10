
SELECT top 20
		--databases.name,
		len(dm_exec_sql_text.text) * (dm_exec_query_stats.execution_count * 1.0) transmitted_bytes,
		dm_exec_query_stats.plan_handle,
		dm_exec_query_stats.last_execution_time ,
	dm_exec_sql_text.text AS TSQL_Text,
	--total_used_grant_kb,
	dm_exec_query_stats.creation_time, 
	dm_exec_query_stats.total_elapsed_time / dm_exec_query_stats.execution_count avg_elapsed_time,
	dm_exec_query_stats.total_rows,
	 dm_exec_query_stats.execution_count,
	dm_exec_query_stats.total_rows / dm_exec_query_stats.execution_count * 1.0 rows_per_execution,
	dm_exec_query_stats.total_worker_time AS total_worker_time,
	 (total_worker_time / execution_count) as avg_worker_time,
	 last_worker_time,
	 max_worker_time,
	 max_elapsed_time, 
	dm_exec_query_stats.total_elapsed_time, 
	dm_exec_query_stats.last_elapsed_time, 
	dm_exec_query_stats.total_logical_reads, 
	dm_exec_query_stats.total_physical_reads, 
	(dm_exec_query_stats.total_grant_kb /execution_count) as avg_grant_kb,
	dm_exec_query_stats.last_grant_kb,
	max_grant_kb
	--dm_exec_query_plan.query_plan
FROM sys.dm_exec_query_stats with (nolock)
CROSS APPLY sys.dm_exec_sql_text(dm_exec_query_stats.plan_handle)
CROSS APPLY sys.dm_exec_query_plan(dm_exec_query_stats.plan_handle)
INNER JOIN sys.databases with (nolock) ON dm_exec_sql_text.dbid = databases.database_id
where 1=1
and not (dm_exec_sql_text.text like '%CREATE%')
order by 
len(dm_exec_sql_text.text) * dm_exec_query_stats.execution_count * 1.0  desc;

