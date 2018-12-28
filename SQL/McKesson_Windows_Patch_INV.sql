select
*
from
(
		select
		exec.execution_id as 'ExecutionId',
		exec.created as 'Rundate',
		exec.status as 'Status',
		auto.name as 'AutomataName'
		from
		IPautomata.execution_variable exec_var, IPautomata.execution exec, IPautomata.automaton auto
		where
		exec_var.execution_id = exec.execution_id
		and exec.automaton_id = auto.automaton_id
		and exec_var.state_scope_id is NULL
		and exec.status != "ABORT_REQUESTED"
		and auto.original_id in (24350,26299,38886,19267,23336,23279,27248,28319,14018)
		and exec_var.name in ('ci_list','ci_hostname','ci_full_list')
		and exec_var.value like ('%ddcwp51041.mckesson.com.mckesson%')
		and exec_var.state_scope_id is NULL
		and exec.created >= "2017-12-01 00:00:010"
		and exec.created <= "2017-12-31 11:59:59"
		order by exec.execution_id desc
) patch_execution
group by patch_execution.AutomataName
order by patch_execution.ExecutionId

