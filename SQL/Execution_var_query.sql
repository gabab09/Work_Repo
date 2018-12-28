select
exec.execution_id,
exec.created,
exec.status,
auto.name
from
IPautomata.execution_variable exec_var, IPautomata.execution exec, IPautomata.automaton auto
where
exec_var.execution_id = exec.execution_id
and exec.automaton_id = auto.automaton_id
and auto.original_id in (24350,26299,38886,19267,23336)
and exec_var.name in ('ci_list','ci_hostname')
and exec_var.value like ('%mmcap5001.mckesson.com.mckesson%')
and exec.created >= DATE_SUB(NOW(), Interval 2 Month)
order by exec.execution_id desc
LIMIT 20

