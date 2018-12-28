select
runningexec.Execution_Id,
runningexec.AutomataName,
runningexec.Execution_Status,
runningexec.Execution_Starttime,
(ROUND(time_to_sec((TIMEDIFF (NOW(),runningexec.Execution_Starttime))) / 60)) as 'OverallExecDuration',
runningexec.CurrentState,
runningexec.CurrentStateStarttime,
(ROUND(time_to_sec((TIMEDIFF (NOW(),runningexec.CurrentStateStarttime))) / 60)) as 'StateExecDuration',
runningexec.HostCommandTimeOut,
runningexec.Radar_Id,
runningexec.RadarStatus,
runningexec.Type

from
(
select
exec.execution_id as 'Execution_Id',
exec.ticket_id as 'Radar_Id',
auto.name 'AutomataName',
exec.status as 'Execution_Status',
exec.created 'Execution_Starttime',
(select exec_state.command_description from IPautomata.state_execution exec_state where  exec_state.state_execution_id = (select max(state_sub.state_execution_id) from IPautomata.state_execution state_sub where state_sub.execution_id = exec.execution_id) LIMIT 1) as 'CurrentState',
(select exec_state.started from IPautomata.state_execution exec_state where  exec_state.state_execution_id = (select max(state_sub.state_execution_id) from IPautomata.state_execution state_sub where state_sub.execution_id = exec.execution_id) LIMIT 1) as 'CurrentStateStarttime',
(select 
host_act.timeout_seconds 
from 
IPautomata.host_command_action host_act, IPautomata.action act, IPautomata.state state, IPautomata.state_execution state_exec 
where host_act.action_id = act.action_id 
and act.state_id = state.state_id 
and state.state_id = state_exec.state_id 
and state_exec.state_execution_id = (select max(state_sub.state_execution_id) from IPautomata.state_execution state_sub where state_sub.execution_id = exec.execution_id)) as 'HostCommandTimeOut',

CASE
WHEN exec.ticket_id IS NULL
then 'TicketLessExecution'
WHEN (select radar.ticket_id from IPradar.tickets radar where radar.ticket_id = exec.ticket_id) IS NOT NULL
then 'OPEN'
else 'CLOSED'
end as 'RadarStatus',

CASE
when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=exec.ticket_id LIMIT 1) is NOT NULL
then ('Incident')
when (select rfc_tkt_map.rfc_id from IPradar.rfc_ticket_mapping rfc_tkt_map where rfc_tkt_map.ticket_id=exec.ticket_id LIMIT 1) is NOT NULL
then ('Change')
else ('Ebond-INC_Or_Request')
end as 'Type'

from
IPautomata.execution exec,IPautomata.automaton auto
where
exec.automaton_id = auto.automaton_id
and exec.status in ('RUNNING','READY','SCHEDULED')
)runningexec
where 
(ROUND(time_to_sec((TIMEDIFF (NOW(),runningexec.Execution_Starttime))) / 60)) > 5
#and runningexec.Execution_Id in (139324)
order by (ROUND(time_to_sec((TIMEDIFF (NOW(),runningexec.Execution_Starttime))) / 60)) desc, runningexec.Execution_Starttime 