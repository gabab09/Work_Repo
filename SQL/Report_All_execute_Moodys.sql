SET @start_date = '2018-03-03 23:59:59'; 
SET @end_date = '2018-03-25 00:00:00'; 
SET @automataid = 'ipautomoodysprod';

select
ticket_rawdata.Client,
ticket_rawdata.TicketOrigin,
ticket_rawdata.RadarTkt,
ticket_rawdata.IPimTicket,
ticket_rawdata.Owner,
ticket_rawdata.IPimCreator,
ticket_rawdata.LastUpdatedBy,
ticket_rawdata.ResolvedBy,
ticket_rawdata.IPimQueue,
ticket_rawdata.Status,
ticket_rawdata.Description,
ticket_rawdata.HostName,
ticket_rawdata.OSType,
ticket_rawdata.State,
case 
	when ((ticket_rawdata.AdditionalInformation REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?') AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'ServiceCheckTimeout'
	when ((ticket_rawdata.AlertType = 'Host') AND ((ticket_rawdata.Service is NULL) OR (ticket_rawdata.Service = '')) AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'HostDown'	
	when ((ticket_rawdata.Service like 'Interface%Errors') AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Interface Errors'
	when ((ticket_rawdata.Service like 'Interface%Utilization')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Interface Utilization'
	when ((ticket_rawdata.Service like 'Interface%Status')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Interface Status'
	when ((ticket_rawdata.Service like 'Disk - /%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Unix Disk'
	when ((ticket_rawdata.Service like 'Disk%-%C:')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Windows System Disk'
	when ((ticket_rawdata.Service like 'Disk%-%:')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Windows Data Disk'
	when ((ticket_rawdata.Service like 'Inodes - /%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Unix Inode'
	when ((ticket_rawdata.Service like 'Oracle Proc -%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Oracle Proc'
	when ((ticket_rawdata.Service like 'Service - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Service'		
	when ((ticket_rawdata.Service like '%Proc - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
		then 'Unix Proc'	
	else
	ticket_rawdata.Service
end
as 'UpdatedService',

ticket_rawdata.Service,
ticket_rawdata.AlertType,
ticket_rawdata.Environment,
ticket_rawdata.Tier,
ticket_rawdata.Site,
ticket_rawdata.DeviceType,
ticket_rawdata.Monitored,
ticket_rawdata.IPsoftManaged,
ticket_rawdata.AutomataName,
ticket_rawdata.AutomataResolved,
ticket_rawdata.AutomataFailed,
ticket_rawdata.AutomataAssisted,
ticket_rawdata.AutomataEscalated,
ticket_rawdata.AutomataPurpose,
ticket_rawdata.AutomataStatus,
#ticket_rawdata.ActualPurpose,
ticket_rawdata.NumberOfAutoamta,
ticket_rawdata.Time_To_Respond,
ticket_rawdata.Time_To_Resolution,
ticket_rawdata.Priority,
ticket_rawdata.CreateDateTime,
ticket_rawdata.ResolveDateTime,
TIMESTAMPDIFF(MINUTE,ticket_rawdata.CreateDateTime,ticket_rawdata.ResolveDateTime) as 'TicketDuration',
ticket_rawdata.ExternalTicket

from

(
	select 
	ipcenter_ticket.ClientClientname as 'Client',
	ipcenter_ticket.ticket_id as 'RadarTkt',
	(select ipim_tkt_map.ipim_id from IPradar.ipim_ticket_mapping ipim_tkt_map where ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'IPimTicket',
	ipcenter_ticket.master_ticket_id as 'MasterTicket',
	
	(select login.Username from auth.LOGIN login where login.LoginID = ipcenter_ticket.owner_id) as 'Owner',
	(select ipim_u.Name from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im, IPim.Users ipim_u  where ipim_im.Creator = ipim_u.id  and ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'IPimCreator',
	(select ipim_u.Name from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im, IPim.Users ipim_u  where ipim_im.LastUpdatedBy = ipim_u.id  and ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'LastUpdatedBy',
	(select ipim_im.LastUpdated from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im where ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'LastUpdated',	

	(select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = ipcenter_ticket.ticket_id  LIMIT 1) as 'ResolvedBy',
	
	(select ipim_q.Name from IPim.Queues ipim_q,IPim.Tickets ipim_tkt,IPradar.ipim_ticket_mapping ipim_radar where ipim_radar.ipim_id = ipim_tkt.id and ipim_tkt.Queue = ipim_q.id and ipim_radar.ticket_id=ipcenter_ticket.ticket_id) as 'IPimQueue',
	(select status_ipradar.status_type from IPradar.status status_ipradar where status_ipradar.status_id = ipcenter_ticket.status_id) as 'Status',
	ipcenter_ticket.description as 'Description',
	
	CASE
		when (ipcenter_ticket.note) like ('%Attribute: ipsoft_source=%')
			then (select CONCAT('IPcollector-',ipradar_tkt_attr.value) from IPradar.ticket_attribute ipradar_tkt_attr where ipradar_tkt_attr.ticket_id = ipcenter_ticket.ticket_id and ipradar_tkt_attr.name = 'ipsoft_source')
		when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
			then ('IPmon')
		when (select rfc_tkt_map.rfc_id from IPradar.rfc_ticket_mapping rfc_tkt_map where rfc_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
			then ('RFC')
		else ('NonIPmonTicket')
	end as 'TicketOrigin',
	
	(select ipim_radar.host_name from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'HostName',
	(select ipim_radar.service from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'Service',
	(select ipim_radar.alert_type from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'AlertType',
	(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Prod-NonProd" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Environment',
	(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Tier" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Tier',
	(select ipcmdb_ci_ass.name from IPcmdb.ci_association ci_ass, IPcmdb.ci ipcmdb_ci_ass,IPradar.ipcmdb_ticket_mapping cmdb_ci where  ci_ass.target_ci_id = ipcmdb_ci_ass.ci_id and ci_ass.source_ci_id = cmdb_ci.ci_id and ci_ass.association_type_id = '3' and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Site',
	(select ipim_radar.state from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'State',

	CASE
		when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
			then ipcenter_ticket.note 
		else 'NA'
	end as 'AdditionalInformation',
	
	CASE 
	when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
	then 
		case
			when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
				then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
			when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
				then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
			else 'NULL'
		end
	else 
		case
			when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
				then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
			when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
				then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
			else 'NULL'
		end
	end as 'DeviceType',
	
	case
		when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Monitored" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 1
			then ('True')
		else ('False')
	end as 'Monitored',
	

	case
		when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 0
			then ('False')
		when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 1
			then ('True')
		else ('NA')
	end as 'IPsoftManaged',
	

	CASE 
		when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
			then 
			(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "OS Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
		else
			(select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "OS Type" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
	end as 'OSType',
	
	
	(select GROUP_CONCAT(auto.name SEPARATOR ', ') from IPautomata.execution exec_sub,IPautomata.automaton auto where exec_sub.automaton_id=auto.automaton_id and exec_sub.ticket_id= ipcenter_ticket.ticket_id  and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'AutomataName',
	(select GROUP_CONCAT(exec_sub.purpose SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'AutomataPurpose',
	(select GROUP_CONCAT(exec_sub.status SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'AutomataStatus',
	
#	CASE 
#	when (((select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) in ('ipautomata',@automataid)) AND ((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= ipcenter_ticket.ticket_id and exec.status not in ('AUTO_ABORTED') and (exec.creator_id is NULL OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec.ticket_id ) is NOT NULL))
#		then 'REMEDIATION'
#
#	when (select tkt_log.action_description from IPradar.ticket_log tkt_log where  tkt_log.ticket_id = ipcenter_ticket.ticket_id and tkt_log.action_description = 'Autoresolve IPmon Alert') is NOT NULL  
#		then 'NA-REMEDIATION'
#
#	when (((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= ipcenter_ticket.ticket_id and exec.status not in ('AUTO_ABORTED') and exec.creator_id is NULL  group by exec.ticket_id) is not NULL))
#		then 'DIAGNOSIS'
#
#	else 'NA-DIAGNOSIS'
#	end as 'ActualPurpose',
(select count(exec_sub.ticket_id) from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION') and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) ) group by exec_sub.ticket_id) as 'NumberOfAutoamta',
	
	(select ipslr_s.automata_resolved from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataResolved',
	(select ipslr_s.automata_failed from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataFailed',
	(select ipslr_s.automata_assisted from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataAssisted',
	(select ipslr_s.automata_escalated from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataEscalated',
	(select SEC_TO_TIME(ipslr_s.time_to_resolution) from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'Time_To_Resolution',
	(select SEC_TO_TIME(ipslr_s.time_to_respond) from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'Time_To_Respond',
	ipcenter_ticket.priority as 'Priority',
	ipcenter_ticket.create_date as 'CreateDateTime',
	ipcenter_ticket.resolve_date as 'ResolveDateTime',
	#DATE_FORMAT(ipcenter_ticket.create_date,'%d-%b') as 'CreateDate',
	#DATE_FORMAT(ipcenter_ticket.create_date,'%h %p') as 'CreateTimeHour',
	#DATE_FORMAT(ipcenter_ticket.create_date,'%M') as 'CreateMonth',
	(select ebond.externalTicketID from ebonding.ticket ebond where ebond.radarTicketID = ipcenter_ticket.ticket_id LIMIT 1) as 'ExternalTicket'
	#ipcenter_ticket.TicketStatus

from 
	(
		select
			tkt_radar_resolved.ticket_id,
			tkt_radar_resolved.master_ticket_id,
			tkt_radar_resolved.description,
			IFNULL(tkt_radar_resolved.criticality_id,'POther') as 'priority',
			tkt_radar_resolved.create_date,
			tkt_radar_resolved.resolve_date,
			#'Closed' as 'TicketStatus',
			tkt_radar_resolved.owner_id,
			tkt_radar_resolved.status_id,
			SUBSTRING(tkt_radar_resolved.note,1,2000) as 'note',
			client.ClientClientname 
		
		from 
		IPradar.tickets_resolved tkt_radar_resolved, auth.CLIENT client 
	
		where 
			tkt_radar_resolved.client_id = client.ClientID 
			and tkt_radar_resolved.description not like ('IPpm%')
			and tkt_radar_resolved.create_date >= @start_date
			and tkt_radar_resolved.create_date <= @end_date
			#and tkt_radar_resolved.master_ticket_id is NULL
			and client.ClientClientname != "IPsoft"
			#and tkt_radar_resolved.ticket_id = 122013
		
		Union
		
		select
			tkt_radar_open.ticket_id,
			tkt_radar_open.master_ticket_id,
			tkt_radar_open.description,
			IFNULL(tkt_radar_open.criticality_id,'POther') as 'priority',
			tkt_radar_open.create_date,
			tkt_radar_open.resolve_date,
			#'Open' as 'TicketStatus',
			tkt_radar_open.owner_id,
			tkt_radar_open.status_id,
			SUBSTRING(tkt_radar_open.note,1,2000) as 'note',
			client.ClientClientname 
		
		from 
		IPradar.tickets tkt_radar_open, auth.CLIENT client 
		
		where 
			tkt_radar_open.client_id = client.ClientID 
			and tkt_radar_open.description not like ('IPpm%')
			and tkt_radar_open.create_date >= @start_date
			and tkt_radar_open.create_date <= @end_date
			#and tkt_radar_open.master_ticket_id is NULL
			and client.ClientClientname != "IPsoft"
			#and tkt_radar_open.ticket_id = 122013
	) ipcenter_ticket
) ticket_rawdata


 



