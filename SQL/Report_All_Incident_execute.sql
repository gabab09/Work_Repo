SET @start_date = '2017-06-01 00:00:00'; 
SET @end_date = '2017-07-01 00:00:00'; 
SET @automataid = 'ipautomckessonprod';

select
*
from
(
select 
(select client.ClientClientname from auth.CLIENT client where client.ClientID = tkt_radar.client_id) as 'ClientName',
tkt_radar.ticket_id as 'RadarTkt',
(select ipim_tkt_map.ipim_id from IPradar.ipim_ticket_mapping ipim_tkt_map where ipim_tkt_map.ticket_id = tkt_radar.ticket_id LIMIT 1) as 'IPimTicket',
(select ebond.externalTicketID from ebonding.ticket ebond where ebond.radarTicketID = tkt_radar.ticket_id LIMIT 1) as 'EbondingTkt',
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

(select ipim_q.Name from IPim.Queues ipim_q,IPim.Tickets ipim_tkt,IPradar.ipim_ticket_mapping ipim_radar where ipim_radar.ipim_id = ipim_tkt.id and ipim_tkt.Queue = ipim_q.id and ipim_radar.ticket_id=tkt_radar.ticket_id) as 'IPimQueue',
tkt_radar.description as 'Description',
ipmon_main.host_name as 'HostName',
ipmon_main.service as 'Service',
ipmon_main.alert_type as 'AlertType',
SUBSTRING(ipmon_main.additional_info,1,200 )  as 'AdditionalInformation',

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

(select cmdb_bd.value from IPcmdb.string_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Service Level" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1) as 'ServiceLevel',
(select cmdb_bd.value from IPcmdb.text_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Environment Specification" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1) as 'EnvSpecification',

CASE 
when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=tkt_radar.ticket_id LIMIT 1) is NOT NULL
then 
	(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "OS Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = tkt_radar.ticket_id LIMIT 1)
else
	(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "OS Type" and cmdb_rdr.ticket_id = tkt_radar.ticket_id LIMIT 1)
end as 'OSType',

(select count(exec_sub.ticket_id) from IPautomata.execution exec_sub where exec_sub.ticket_id= tkt_radar.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) ) group by exec_sub.ticket_id) as 'NumberOfAutoamta',

(select GROUP_CONCAT(auto.name SEPARATOR ', ') from IPautomata.execution exec_sub,IPautomata.automaton auto where exec_sub.automaton_id=auto.automaton_id and exec_sub.ticket_id= tkt_radar.ticket_id  and exec_sub.status not in ('AUTO_ABORTED') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'AutomataName',

(select count(1) from IPradar.tickets_resolved k where k.master_ticket_id = tkt_radar.ticket_id) as 'NumberOfCorrelatedTicket',
IFNULL(tkt_radar.criticality_id,'POther') as 'Priority',
tkt_radar.create_date as 'CreateDateTime',
tkt_radar.resolve_date as 'ResolveDateTime',
DATE_FORMAT(tkt_radar.create_date,'%d-%b') as 'CreateDate',
DATE_FORMAT(tkt_radar.create_date,'%h %p') as 'CreateTimeHour',
DATE_FORMAT(tkt_radar.create_date,'%M') as 'CreateMonth',
'Close' as 'IPimTicketStatus'

from 
IPradar.tickets_resolved tkt_radar, IPradar.ipmon_ticket_mapping ipmon_main
where 
tkt_radar.ticket_id = ipmon_main.ticket_id
and tkt_radar.description not like ('IPpm%')
and tkt_radar.create_date >= @start_date
and tkt_radar.create_date <= @end_date
and tkt_radar.master_ticket_id is NULL
and ipmon_main.service REGEXP 'Swap Usage|Total Procs|Zombies|SAP\s|Read\+Write Disk Status|Proc \-|Perf Data|Inodes \-|Disk \- \/|Linux CPU Usage|Linux Messages Log|Linux SU Log|Load Average|AIX|Tivoli|System Uptime|CPU Utilization'
and tkt_radar.note not REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?'
)automata_execution
where
automata_execution.OSType != 'Windows'


