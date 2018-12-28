SET @start_date = '2017-12-10 00:00:00'; 
SET @end_date = '2017-12-14 00:00:00'; 
SET @automataid = 'ipautomckessonprod';

select
tkt_resolved.ClientName,
tkt_resolved.RadarTkt,
tkt_resolved.IPimTicket,
tkt_resolved.IPimCreator,
tkt_resolved.ResolvedBy,
tkt_resolved.ActualPurpose,
tkt_resolved.TicketOrigin,
tkt_resolved.IPimQueue,
tkt_resolved.Description,
tkt_resolved.State,
tkt_resolved.HostName,
tkt_resolved.Service,
case 
	when ((tkt_resolved.AdditionalInformation REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?') AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Service Check Timeout'
	when ((tkt_resolved.Service like 'Interface%Errors') AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Interface Errors'
	when ((tkt_resolved.Service like 'Interface%Utilization')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Interface Utilization'
	when ((tkt_resolved.Service like 'Interface%Status')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Interface Status'
	when ((tkt_resolved.Service like 'Disk - /%')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Unix Disk'
	when ((tkt_resolved.Service like 'Inodes - /%')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Unix Inode'
	when ((tkt_resolved.Service like 'Oracle Proc -%')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Oracle Proc'
	when ((tkt_resolved.Service like '%Proc - %')  AND (tkt_resolved.TicketOrigin = 'IPmonAlert'))
		then 'Unix Proc'	
	else
	tkt_resolved.Service
end
as 'UpdatedService',
tkt_resolved.AlertType,
tkt_resolved.DeviceType,
tkt_resolved.Monitored,
tkt_resolved.IPsoftManaged,
tkt_resolved.OSType,
tkt_resolved.NumberOfAutoamta,
tkt_resolved.AutomataName,
tkt_resolved.Purpose,
tkt_resolved.Status,
tkt_resolved.AutomataResolved,
tkt_resolved.AutomataFailed,
tkt_resolved.AutomataAssisted,
tkt_resolved.AutomataEscalated,
#tkt_resolved.EngineerTimeToDiag,
#tkt_resolved.EngineerTimeToRem,
#tkt_resolved.EngineerTimeToDiag_Seperator,
#tkt_resolved.EngineerTimeToRem_Seperator,
tkt_resolved.NumberOfCorrelatedTicket,
tkt_resolved.Priority,
tkt_resolved.CreateDateTime,
tkt_resolved.ResolveDateTime,
tkt_resolved.CreateDate,
tkt_resolved.CreateTimeHour,
tkt_resolved.CreateMonth,
tkt_resolved.IPimTicketStatus

from
(
select 
client.ClientClientname  as 'ClientName',
tkt_radar.ticket_id as 'RadarTkt',
(select ipim_tkt_map.ipim_id from IPradar.ipim_ticket_mapping ipim_tkt_map where ipim_tkt_map.ticket_id = tkt_radar.ticket_id LIMIT 1) as 'IPimTicket',
(select ipim_u.Name from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im, IPim.Users ipim_u  where ipim_im.Creator = ipim_u.id  and ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = tkt_radar.ticket_id LIMIT 1) as 'IPimCreator',
(select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = tkt_radar.ticket_id  LIMIT 1) as 'ResolvedBy',

CASE 
	when (((select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = tkt_radar.ticket_id LIMIT 1) in ('ipautomata',@automataid)) AND ((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= tkt_radar.ticket_id and exec.status not in ('AUTO_ABORTED') and (exec.creator_id is NULL OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec.ticket_id ) is NOT NULL))
		then 'REMEDIATION'

	when (select tkt_log.action_description from IPradar.ticket_log tkt_log where  tkt_log.ticket_id = tkt_radar.ticket_id and tkt_log.action_description = 'Autoresolve IPmon Alert') is NOT NULL  
		then 'NA-REMEDIATION'

	when (((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= tkt_radar.ticket_id and exec.status not in ('AUTO_ABORTED') and exec.creator_id is NULL  group by exec.ticket_id) is not NULL))
		then 'DIAGNOSIS'

	else 'NA-DIAGNOSIS'
end as 'ActualPurpose',

CASE
	when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
		then ('IPmonAlert')
	when (select rfc_tkt_map.rfc_id from IPradar.rfc_ticket_mapping rfc_tkt_map where rfc_tkt_map.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
		then ('RFC')
	else ('NonIPmonTicket')
end as 'TicketOrigin',

(select ipim_q.Name from IPim.Queues ipim_q,IPim.Tickets ipim_tkt,IPradar.ipim_ticket_mapping ipim_radar where ipim_radar.ipim_id = ipim_tkt.id and ipim_tkt.Queue = ipim_q.id and ipim_radar.ticket_id=tkt_radar.ticket_id) as 'IPimQueue',
tkt_radar.description as 'Description',
(select ipim_radar.state from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=tkt_radar.ticket_id ) as 'State',
#(select ipim_radar.additional_info from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=tkt_radar.ticket_id ) as 'AdditionalInformation',

CASE
	when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
		then SUBSTRING(tkt_radar.note,1,1000) 
	else 'NA'
end as 'AdditionalInformation',


(select ipim_radar.host_name from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=tkt_radar.ticket_id ) as 'HostName',
(select ipim_radar.service from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=tkt_radar.ticket_id ) as 'Service',


(select ipim_radar.alert_type from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=tkt_radar.ticket_id ) as 'AlertType',


CASE 
when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
then 
	case
		when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1) is NOT NULL
			then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1)
		when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1) is NOT NULL
			then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1)
		else 'NULL'
	end
else 
	case
		when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = tkt_radar.ticket_id LIMIT 1) is NOT NULL
			then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = tkt_radar.ticket_id LIMIT 1)
		when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = tkt_radar.ticket_id LIMIT 1) is NOT NULL
			then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = tkt_radar.ticket_id LIMIT 1)
		else 'NULL'
	end
end as 'DeviceType',

case
	when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Monitored" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1) = 1
		then ('True')
	else ('False')
end as 'Monitored',

case
	when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1) = 0
		then ('False')
	when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1) = 1
		then ('True')
	else ('NA')
end as 'IPsoftManaged',

CASE 
	when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
		then 
		(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "OS Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1)
	else
		(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "OS Type" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1)
end as 'OSType',

(select count(exec_sub.ticket_id) from IPautomata.execution exec_sub where exec_sub.ticket_id= tkt_radar.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) ) group by exec_sub.ticket_id) as 'NumberOfAutoamta',

(select GROUP_CONCAT(auto.name SEPARATOR ', ') from IPautomata.execution exec_sub,IPautomata.automaton auto where exec_sub.automaton_id=auto.automaton_id and exec_sub.ticket_id= tkt_radar.ticket_id  and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'AutomataName',

(select GROUP_CONCAT(exec_sub.purpose SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= tkt_radar.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'Purpose',

(select GROUP_CONCAT(exec_sub.status SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= tkt_radar.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'Status',

(select ipslr_s.automata_resolved from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=tkt_radar.ticket_id LIMIT 1) as 'AutomataResolved',
(select ipslr_s.automata_failed from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=tkt_radar.ticket_id LIMIT 1) as 'AutomataFailed',
(select ipslr_s.automata_assisted from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=tkt_radar.ticket_id LIMIT 1) as 'AutomataAssisted',
(select ipslr_s.automata_escalated from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=tkt_radar.ticket_id LIMIT 1) as 'AutomataEscalated',
#(select sum(auto.engineer_time_to_diagnose) from IPautomata.automaton auto,IPautomata.execution exec_sub where auto.automaton_id = exec_sub.automaton_id and exec_sub.ticket_id=tkt_radar.ticket_id and exec_sub.purpose != 'ESCALATION' and exec_sub.status =  'COMPLETE' and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToDiag",
#(select sum(auto.engineer_time_to_remediate) from IPautomata.automaton auto,IPautomata.execution exec_sub where auto.automaton_id = exec_sub.automaton_id and exec_sub.ticket_id=tkt_radar.ticket_id and exec_sub.purpose != 'ESCALATION' and exec_sub.status =  'COMPLETE' and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) ) as "EngineerTimeToRem",
#(select GROUP_CONCAT(auto.engineer_time_to_diagnose SEPARATOR ', ') from IPautomata.automaton auto,IPautomata.execution exec_sub where auto.automaton_id = exec_sub.automaton_id and exec_sub.ticket_id=tkt_radar.ticket_id and exec_sub.purpose != 'ESCALATION' and exec_sub.status =  'COMPLETE' and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToDiag_Seperator",
#(select GROUP_CONCAT(auto.engineer_time_to_remediate SEPARATOR ', ') from IPautomata.automaton auto,IPautomata.execution exec_sub where auto.automaton_id = exec_sub.automaton_id and exec_sub.ticket_id=tkt_radar.ticket_id and exec_sub.purpose != 'ESCALATION' and exec_sub.status =  'COMPLETE' and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR auto.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToRem_Seperator",
(select count(1) from IPradar.tickets_resolved k where k.master_ticket_id = tkt_radar.ticket_id) as 'NumberOfCorrelatedTicket',
IFNULL(tkt_radar.criticality_id,'POther') as 'Priority',
tkt_radar.create_date as 'CreateDateTime',
tkt_radar.resolve_date as 'ResolveDateTime',
DATE_FORMAT(tkt_radar.create_date,'%d-%b') as 'CreateDate',
DATE_FORMAT(tkt_radar.create_date,'%h %p') as 'CreateTimeHour',
DATE_FORMAT(tkt_radar.create_date,'%M') as 'CreateMonth',
'Close' as 'IPimTicketStatus'

from 
IPradar.tickets_resolved tkt_radar, auth.CLIENT client 

where 
tkt_radar.client_id = client.ClientID 
and tkt_radar.description not like ('IPpm%')
and tkt_radar.create_date >= @start_date
and tkt_radar.create_date <= @end_date
and tkt_radar.master_ticket_id is NULL

)tkt_resolved




