SET @start_date = '2018-10-15 12:00:00';
SET @end_date = '2018-10-16 00:00:00'; 


select
APPHOST_EXEC.AppHost as 'APP_Host',
count(1) as 'Execution Count'
from
(
	select
		SUBSTRING_INDEX(exec_log.thread,',',1) as 'AppHost'
	from
		IPautomata.execution_log exec_log,IPautomata.execution exec
	where
		exec.execution_id = exec_log.execution_id
		and exec_log.description = "Execution completed"
		and exec.created >= @start_date
		and exec.created <= @end_date
)
APPHOST_EXEC
group by APPHOST_EXEC.AppHost