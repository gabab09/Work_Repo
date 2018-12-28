select 
automata_execution_rfc.PatchHost,
case when (automata_execution_rfc.ExecutionId) is NOT NULL then automata_execution_rfc.ExecutionId else '-' end as "ExecutionId",
case when (automata_execution_rfc.AutomataStatus) is NOT NULL then automata_execution_rfc.AutomataStatus else '-' end as "AutomataStatus",
automata_execution_rfc.RFC,

case when (automata_execution_rfc.ExecutionId) is NOT NULL then
	(select 
	tkt_close.ticket_id 
	from IPradar.tickets_resolved  tkt_close where 
	tkt_close.note like CONCAT("%executionID=",automata_execution_rfc.ExecutionId,"%") 
	and tkt_close.note like CONCAT("%",automata_execution_rfc.PatchHost,"%") 
	and tkt_close.description not like "%McKesson Windows Patching - Verify Patches Installed%" 
	and tkt_close.create_date >= DATE_SUB(NOW(), INTERVAL 2 DAY)  
	union 
	select 
	tkt.ticket_id 
	from IPradar.tickets tkt where 
	tkt.note like CONCAT("%executionID=",automata_execution_rfc.ExecutionId,"%") 
	and tkt.note like CONCAT("%",automata_execution_rfc.PatchHost,"%") 
	and tkt.description not like "%McKesson Windows Patching - Verify Patches Installed%" 
	and tkt.create_date >= DATE_SUB(NOW(), INTERVAL 2 DAY)) 
else 
	(select 
	tkt_close.ticket_id 
	from 
	IPradar.tickets_resolved  tkt_close	where 
	tkt_close.note like CONCAT("%rfcID=",automata_execution_rfc.RFC,"%") 
	and tkt_close.note like CONCAT("%",automata_execution_rfc.PatchHost,"%") 
	and  tkt_close.description not like "%McKesson Windows Patching - Verify Patches Installed%" 
	and tkt_close.create_date >= DATE_SUB(NOW(), INTERVAL 2 DAY)  
	union 
	select 
	tkt.ticket_id 
	from IPradar.tickets tkt where 
	tkt.note like CONCAT("%rfcID=",automata_execution_rfc.RFC,"%") 
	and tkt.note like CONCAT("%",automata_execution_rfc.PatchHost,"%") 
	and tkt.description not like "%McKesson Windows Patching - Verify Patches Installed%" 
	and tkt.create_date >= DATE_SUB(NOW(), INTERVAL 2 DAY))
end as "RadarTicket"


from 

(
	select 
	rfc_ci.CI_NAME as 'PatchHost',
	(select 
	exec.execution_id
	from 
	IPautomata.execution exec,IPautomata.automaton auto,IPautomata.execution_variable var
	where
	exec.automaton_id = auto.automaton_id and exec.execution_id = var.execution_id
	and auto.name = "Wrapper: Windows Update"
	and exec.creator_id = 2580 
	and var.name = "ci_hostname" 
	and var.value = rfc_ci.CI_NAME
	and var.state_scope_id is NULL
	and exec.created >= DATE_SUB(NOW(), INTERVAL 2 DAY)
	order by exec.created desc 
	LIMIT 1) as 'ExecutionId',
	(select 
	exec.status
	from 
	IPautomata.execution exec,IPautomata.automaton auto,IPautomata.execution_variable var
	where
	exec.automaton_id = auto.automaton_id and exec.execution_id = var.execution_id
	and auto.name = "Wrapper: Windows Update"
	and exec.creator_id = 2580 
	and var.name = "ci_hostname" 
	and var.value = rfc_ci.CI_NAME
	and var.state_scope_id is NULL
	and exec.created >= DATE_SUB(NOW(), INTERVAL 2 DAY)
	order by exec.created desc 
	LIMIT 1) as 'AutomataStatus',
	rfc_ci.RFCID as 'RFC'
from
	(select 
	rfc_tkt.rfc_id as 'RFCID',
	ci.name as 'CI_NAME'
	from 
	IPradar.rfc_ticket_mapping rfc_tkt,IPcm.rfc_ci rfc_ci,IPcmdb.ci ci 
	where 
	rfc_tkt.rfc_id = rfc_ci.rfc_id 
	and rfc_ci.ci_id = ci.ci_id 
	and  rfc_tkt.workflow_name = "McKesson Windows Patching" 
	and rfc_tkt.creation_date >= DATE_SUB(NOW(), INTERVAL 2 DAY)
	order by rfc_tkt.creation_date desc) rfc_ci
) automata_execution_rfc