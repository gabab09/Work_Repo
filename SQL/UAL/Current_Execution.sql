select
exec.execution_id,
(select exec_var.value from IPautomata.automaton auto1, IPautomata.execution exec1, IPautomata.execution_variable exec_var where auto1.automaton_id = exec1.automaton_id and exec1.execution_id = exec_var.execution_id and exec_var.name = "ci_name" and auto1.original_id = 923 and exec1.execution_id = exec.execution_id LIMIT 1 ) as 'CI',
exec.ticket_id,
exec.created,
exec.status,
auto.name,
#TIMEDIFF(NOW(),exec.created)
ROUND(time_to_sec((TIMEDIFF(NOW(), exec.created))) / 60) as 'Duration'

from
IPautomata.automaton auto, IPautomata.execution exec
where
auto.automaton_id = exec.automaton_id
and auto.original_id = 923
and exec.ticket_id = 1103
#and exec.status not in ('COMPLETE')
and exec.created >= DATE_SUB(NOW(), Interval 2 HOUR)
order by exec.status desc, exec.created desc