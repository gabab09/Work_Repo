SET @start_date = '2017-12-15 23:59:59'; 
SET @end_date = '2018-01-05 00:00:00'; 
SET @automataid = 'ipautomckessonprod';

select
auto.name as 'AutomataName',
count(1) as 'RunCount',
(
	select
	count(1)
	from
	IPautomata.execution exec_sub, IPautomata.automaton auto_sub
	where
	exec_sub.automaton_id = auto_sub.automaton_id
	and auto_sub.name = auto.name 
	and exec_sub.automaton_id = exec.automaton_id 
	and exec_sub.status = 'COMPLETE'
	and exec_sub.purpose = 'REMEDIATION'
	and exec_sub.created >= @start_date
	and exec_sub.created <= @end_date
	group by auto_sub.name
) as 'REMEDIATION_COUNT',
(
	select
	count(1)
	from
	IPautomata.execution exec_sub, IPautomata.automaton auto_sub
	where
	exec_sub.automaton_id = auto_sub.automaton_id
	and auto_sub.name = auto.name 
	and exec_sub.automaton_id = exec.automaton_id 
	and exec_sub.status = 'COMPLETE'
	and exec_sub.purpose = 'DIAGNOSIS'
	and exec_sub.created >= @start_date
	and exec_sub.created <= @end_date
	group by auto_sub.name
) as 'DIAGNOSIS_COUNT',
(
	select
	count(1)
	from
	IPautomata.execution exec_sub, IPautomata.automaton auto_sub
	where
	exec_sub.automaton_id = auto_sub.automaton_id
	and auto_sub.name = auto.name 
	and exec_sub.automaton_id = exec.automaton_id 
	and exec_sub.status = 'COMPLETE'
	and exec_sub.purpose = 'ESCALATION'
	and exec_sub.created >= @start_date
	and exec_sub.created <= @end_date
	group by auto_sub.name
) as 'ESCALATION_COUNT',
(
	select
	count(1)
	from
	IPautomata.execution exec_sub, IPautomata.automaton auto_sub
	where
	exec_sub.automaton_id = auto_sub.automaton_id
	and auto_sub.name = auto.name 
	and exec_sub.automaton_id = exec.automaton_id 
	and exec_sub.status = 'FAILED'
	and exec_sub.created >= @start_date
	and exec_sub.created <= @end_date
	group by auto_sub.name
) as 'IMPACTED_COUNT'

from
IPautomata.execution exec, IPautomata.automaton auto
where
exec.automaton_id =  auto.automaton_id
and exec.status not in ('AUTO_ABORTED')
#and (exec.creator_id is NULL OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR  exec.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal'))
and exec.created >= @start_date
and exec.created <= @end_date
group by auto.name 

