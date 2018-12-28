select
UD_AGENT.ServerName,
UD_AGENT.Execution_ID,
UD_AGENT.OSType,
CASE
	WHEN ((UD_AGENT.Status = 'COMPLETE') AND (UD_AGENT.Purpose = 'REMEDIATION') AND (UD_AGENT.Last_State_Name = 'Success'))
		then 'COMPLETE'
	WHEN ((UD_AGENT.Last_State_Command like '%xCopy%C%McKesson%UD_Agent_installer%') OR (UD_AGENT.Last_State_Command like '%scp%/home/ipautomckessonprod/ud_package%d25fc0a%'))
		then 'Source Copy Failed'
	WHEN (UD_AGENT.Last_State_Command like '%cd /tmp/ud_package/%')
		then 'Permission Denied for d25fc0a to do SCP or Passwpord Expired'
	WHEN ((UD_AGENT.Last_State_Stdout like '%scp%/tmp/ud_package%')  OR (UD_AGENT.Last_State_Stdout like '%password%has%expired%') OR  (UD_AGENT.Last_State_Stdout like '%scp %'))
		then 'Permission Denied for d25fc0a to do SCP or Passwpord Expired'
	WHEN ((UD_AGENT.Last_State_Command like '%sed%-i%D_UNIQUE_ID=%UD_UNIQUE_ID=%g%') OR (UD_AGENT.Last_State_Command like '%UD_UNIQUE_ID%'))
		then 'Unique ID Setup Failed'		
	WHEN (UD_AGENT.Last_State_Name like '%Connection Check Failed%')
		then 'Connection Failed'		
	WHEN (UD_AGENT.Last_State_Name like '%CI%Decommissioned%')
		then 'Decommissioned'		
	WHEN (UD_AGENT.Last_State_Name like '%CI%Not%in%CMDB%')
		then 'CI not in CMDB'		
	WHEN (UD_AGENT.Last_State_Name like '%Install%UD%agent%')
		then 'Install Failed'		
	WHEN ((UD_AGENT.Last_State_Name like '%Get%Host%Details%') OR (UD_AGENT.Last_State_Name like '%Validate%CI%') OR (UD_AGENT.Last_State_Name like '%CI%has%no%IPmon%'))
		then 'No Monitoring'			
	WHEN ((UD_AGENT.Status = 'RUNNING') AND (UD_AGENT.Last_State_Command like '%Timed%Wait%'))
		then 'AutomataHung'		
	else 
	'Other'
End as 'Status',
UD_AGENT.Status as 'AutomataStatus',
UD_AGENT.Purpose,
UD_AGENT.Last_State_Name,
UD_AGENT.Last_State_Command,
UD_AGENT.Last_State_Stdout,
UD_AGENT.Last_State_Stderr,
UD_AGENT.RFC

from
(	
	select exec_var.value as 'ServerName',
	exec.execution_id as 'Execution_ID',
	exec.status as 'Status',
	exec.purpose as 'Purpose',
	(select rfc_tkt.rfc_id  from IPradar.rfc_ticket_mapping rfc_tkt where rfc_tkt.ticket_id = exec.ticket_id) as 'RFC',
	(
		select cmdb_st.value
		from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcmdb.ci ci where
		cmdb_st.datum_id = cmdb_attr.datum_id
		and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id
		and cmdb_attr.ci_id = ci.ci_id
		and cmdb_attrdef.name = "OS Type"
		and ci.name = exec_var.value LIMIT 1
	) as 'OSType',
	state.name as Last_State_Name,
	state_execution.command_description as Last_State_Command,
	state_execution.stdout as Last_State_Stdout,
	state_execution.stderr as Last_State_Stderr
	
	from IPautomata.state_execution, IPautomata.state,
	(
		select max(state_execution_id) as state_execution_id
		from IPautomata.state_execution, IPautomata.execution exec, IPautomata.automaton auto
		where state_execution.execution_id=exec.execution_id
		and exec.automaton_id = auto.automaton_id
		and auto.original_id in ('28203','28667')
		#and exec.ticket_id in ('2737791','2737726','2737729','2738443','2732696','2732773') 
		and exec.ticket_id in ('2743109')
		group by exec.execution_id
	) as last_state, IPautomata.execution exec, IPautomata.execution_variable exec_var
	
	where last_state.state_execution_id=state_execution.state_execution_id
	and state_execution.state_id=state.state_id
	and exec.execution_id=state_execution.execution_id
	and exec_var.execution_id = exec.execution_id
	and exec_var.name = "server_name"
	and exec_var.state_scope_id is NULL
) as UD_AGENT