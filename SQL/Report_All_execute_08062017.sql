SET @start_date = '2017-07-06 04:13:00'; #7/6/2017  4:13:10 PM
SET @end_date = '2017-07-30 00:00:00'; 
SET @automataid = 'ipautomckessonprod';

select
*
from
(
select 
(select client.ClientClientname from auth.CLIENT client where client.ClientID = a.client_id) as 'ClientName',
a.ticket_id as 'RadarTkt',
(select ipim_tkt_map.ipim_id from IPradar.ipim_ticket_mapping ipim_tkt_map where ipim_tkt_map.ticket_id = a.ticket_id LIMIT 1) as 'IPimTicket',
(select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = a.ticket_id  LIMIT 1) as 'ResolvedBy',

CASE 
when (((select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = a.ticket_id LIMIT 1) in ('ipautomata',@automataid)) AND ((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= a.ticket_id and exec.status not in ('AUTO_ABORTED') and (exec.creator_id is NULL OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec.ticket_id ) is NOT NULL))
then 'REMEDIATION'

when (select tkt_log.action_description from IPradar.ticket_log tkt_log where  tkt_log.ticket_id = a.ticket_id and tkt_log.action_description = 'Autoresolve IPmon Alert') is NOT NULL  
then 'NA-REMEDIATION'

when (((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= a.ticket_id and exec.status not in ('AUTO_ABORTED') and exec.creator_id is NULL  group by exec.ticket_id) is not NULL))
then 'DIAGNOSIS'

else 'NA-DIAGNOSIS'
end as 'ActualPurpose',

CASE
when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=a.ticket_id LIMIT 1) is NOT NULL
then ('Incident')
when (select rfc_tkt_map.rfc_id from IPradar.rfc_ticket_mapping rfc_tkt_map where rfc_tkt_map.ticket_id=a.ticket_id LIMIT 1) is NOT NULL
then ('Change')
else ('Request')
end as 'Ticket Origin',

(select c.Name from IPim.Queues c,IPim.Tickets b,IPradar.ipim_ticket_mapping z where z.ipim_id = b.id and b.Queue = c.id and z.ticket_id=a.ticket_id) as 'IPimQueue',
a.description as 'Description',
(select c.state from IPradar.ipmon_ticket_mapping c where c.ticket_id=a.ticket_id ) as 'State',
#(select c.additional_info from IPradar.ipmon_ticket_mapping c where c.ticket_id=a.ticket_id ) as 'AdditionalInformation',
(select c.host_name from IPradar.ipmon_ticket_mapping c where c.ticket_id=a.ticket_id ) as 'HostName',
(select c.service from IPradar.ipmon_ticket_mapping c where c.ticket_id=a.ticket_id ) as 'Service',
(select c.alert_type from IPradar.ipmon_ticket_mapping c where c.ticket_id=a.ticket_id ) as 'AlertType',


CASE 
when (select x.rfc_id from IPradar.rfc_ticket_mapping x where x.ticket_id=a.ticket_id LIMIT 1) is NOT NULL
then 
	case
	when (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcm.rfc_ci w,IPradar.rfc_ticket_mapping rfctktmap where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Type" and w.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = a.ticket_id LIMIT 1) is NOT NULL
	then (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcm.rfc_ci w,IPradar.rfc_ticket_mapping rfctktmap where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Type" and w.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = a.ticket_id LIMIT 1)
	when (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcm.rfc_ci w,IPradar.rfc_ticket_mapping rfctktmap where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Database Type" and w.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = a.ticket_id LIMIT 1) is NOT NULL
	then (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcm.rfc_ci w,IPradar.rfc_ticket_mapping rfctktmap where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Database Type" and w.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = a.ticket_id LIMIT 1)
	else 'NULL'
	end
else 
	case
	when (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Type" and w.ticket_id = a.ticket_id LIMIT 1) is NOT NULL
	then (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Type" and w.ticket_id = a.ticket_id LIMIT 1)
	when (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Database Type" and w.ticket_id = a.ticket_id LIMIT 1) is NOT NULL
	then (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Database Type" and w.ticket_id = a.ticket_id LIMIT 1)
	else 'NULL'
	end
end as 'DeviceType',

case
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Monitored" and w.ticket_id = a.ticket_id LIMIT 1) = 1
then ('True')
else ('False')
end as 'Monitored',

case
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "IPsoft Managed" and w.ticket_id = a.ticket_id LIMIT 1) = 0
then ('False')
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "IPsoft Managed" and w.ticket_id = a.ticket_id LIMIT 1) = 1
then ('True')
else ('NA')
end as 'IPsoftManaged',

CASE 
when (select x.rfc_id from IPradar.rfc_ticket_mapping x where x.ticket_id=a.ticket_id LIMIT 1) is NOT NULL
then 
	(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcm.rfc_ci w,IPradar.rfc_ticket_mapping rfctktmap where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "OS Type" and w.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = a.ticket_id LIMIT 1)
else
	(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "OS Type" and w.ticket_id = a.ticket_id LIMIT 1)
end as 'OSType',

(select count(q.ticket_id) from IPautomata.execution q where q.ticket_id= a.ticket_id and q.status not in ('AUTO_ABORTED') and (q.creator_id is NULL OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) ) group by q.ticket_id) as 'NumberOfAutoamta',

(select GROUP_CONCAT(r.name SEPARATOR ', ') from IPautomata.execution q,IPautomata.automaton r where q.automaton_id=r.automaton_id and q.ticket_id= a.ticket_id  and q.status not in ('AUTO_ABORTED') and  (q.creator_id is NULL OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by q.ticket_id) as 'AutomataName',

(select GROUP_CONCAT(q.purpose SEPARATOR ', ') from IPautomata.execution q where q.ticket_id= a.ticket_id and q.status not in ('AUTO_ABORTED') and  (q.creator_id is NULL OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by q.ticket_id) as 'Purpose',

(select GROUP_CONCAT(q.status SEPARATOR ', ') from IPautomata.execution q where q.ticket_id= a.ticket_id and q.status not in ('AUTO_ABORTED') and  (q.creator_id is NULL OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by q.ticket_id) as 'Status',

(select q.automata_resolved from IPslr.ticket_summary q where q.ticket_id=a.ticket_id LIMIT 1) as 'AutomataResolved',
(select q.automata_failed from IPslr.ticket_summary q where q.ticket_id=a.ticket_id LIMIT 1) as 'AutomataFailed',
(select q.automata_assisted from IPslr.ticket_summary q where q.ticket_id=a.ticket_id LIMIT 1) as 'AutomataAssisted',
(select q.automata_escalated from IPslr.ticket_summary q where q.ticket_id=a.ticket_id LIMIT 1) as 'AutomataEscalated',
(select sum(q.engineer_time_to_diagnose) from IPautomata.automaton q,IPautomata.execution s where q.automaton_id = s.automaton_id and s.ticket_id=a.ticket_id and s.purpose != 'ESCALATION' and s.status =  'COMPLETE' and (s.creator_id is NULL OR s.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToDiag",
(select sum(q.engineer_time_to_remediate) from IPautomata.automaton q,IPautomata.execution s where q.automaton_id = s.automaton_id and s.ticket_id=a.ticket_id and s.purpose != 'ESCALATION' and s.status =  'COMPLETE' and (s.creator_id is NULL OR s.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) ) as "EngineerTimeToRem",
(select GROUP_CONCAT(q.engineer_time_to_diagnose SEPARATOR ', ') from IPautomata.automaton q,IPautomata.execution s where q.automaton_id = s.automaton_id and s.ticket_id=a.ticket_id and s.purpose != 'ESCALATION' and s.status =  'COMPLETE' and (s.creator_id is NULL OR s.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToDiag_Seperator",
(select GROUP_CONCAT(q.engineer_time_to_remediate SEPARATOR ', ') from IPautomata.automaton q,IPautomata.execution s where q.automaton_id = s.automaton_id and s.ticket_id=a.ticket_id and s.purpose != 'ESCALATION' and s.status =  'COMPLETE' and (s.creator_id is NULL OR s.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR q.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR q.creator_id = (select LoginID from auth.LOGIN where Username = @automataid))) as "EngineerTimeToRem_Seperator",
(select count(1) from IPradar.tickets_resolved k where k.master_ticket_id = a.ticket_id) as 'NumberOfCorrelatedTicket',
a.create_date as 'CreateDateTime',
a.resolve_date as 'ResolveDateTime',
DATE_FORMAT(a.create_date,'%d-%b') as 'CreateDate',
DATE_FORMAT(a.create_date,'%h %p') as 'CreateTimeHour',
DATE_FORMAT(a.create_date,'%M') as 'CreateMonth',
'Close' as 'IPimTicketStatus'

from 
IPradar.tickets_resolved a

where 
a.description not like ('IPpm%')
and a.create_date >= @start_date
and a.create_date <= @end_date
and a.master_ticket_id is NULL

)automata_execution


