#SET @ciname = 'itds-205.oc.mckesson';
SET @ciname = 'itps-058.apps.mckesson';
SET @wfname = 'McKesson Windows Patching Phase 2';
SET @automata_patching = 'Wrapper: Windows Update';
SET @automata_patching_trigger = 'Patching_Do_Patch';
SET @date_offset = '7';


select
server_patching_details.CIName,
(select exec.ticket_id from IPautomata.execution exec where exec.execution_id = server_patching_details.ExecutionId) as 'ExecRadarId',
server_patching_details.RFC,
server_patching_details.RFC_Starttime,
server_patching_details.ExecutionId,
(select exec.status from IPautomata.execution exec where exec.execution_id = server_patching_details.ExecutionId) as 'ExecStatus',
(select DATE_SUB(exec.created, INTERVAL @date_offset HOUR) from IPautomata.execution exec where exec.execution_id = server_patching_details.ExecutionId) as 'ExecStTime'
from
(
select
ci.name as 'CIName', 
rfc.rfc_id as 'RFC',
DATE_SUB(rfc.planned_start_date, INTERVAL @date_offset HOUR) as 'RFC_Starttime',
(select 
exec_sub.execution_id 
from IPautomata.execution_variable exec_var_sub, IPautomata.execution exec_sub, IPautomata.automaton automaton_sub 
where exec_sub.automaton_id = automaton_sub.automaton_id 
and exec_var_sub.execution_id = exec_sub.execution_id
and automaton_sub.approval_status = "APPROVED" 
and automaton_sub.name in (@automata_patching,@automata_patching_trigger)
and exec_var_sub.name = "ci_hostname"
and exec_var_sub.value = @ciname
and exec_sub.created >= DATE_SUB(NOW(), Interval 5 DAY) 
order by exec_sub.execution_id desc 
LIMIT 1) as 'ExecutionId'


from
IPcm.rfc rfc, IPcm.rfc_ci rfc_ci, IPcm.workflow wf, IPcmdb.ci ci 
where 
rfc.workflow_id = wf.workflow_id 
and rfc.rfc_id = rfc_ci.rfc_id 
and rfc_ci.ci_id = ci.ci_id 
and rfc.current_version_id is NULL 
and wf.name = @wfname
and ci.name = @ciname
and rfc.created >= DATE_SUB(NOW(), Interval 5 DAY) 
LIMIT 1
) server_patching_details


