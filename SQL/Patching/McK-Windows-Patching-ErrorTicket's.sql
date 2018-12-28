select 

ipim_map.description as 'Description',
ipim_map.ticket_id as 'RadarTkt',
ipim_map.ipim_id as 'IpimTkt',
ipim_map.creation_date as 'CreateDate',
ipim.Status as 'TktStatus',
(select cmdb_tktmap.name from IPradar.ipcmdb_ticket_mapping cmdb_tktmap where cmdb_tktmap.ticket_id = ipim_map.ticket_id LIMIT 1) as 'CI',
(select x.Name from IPim.Users x, IPim.Tickets y,IPradar.ipim_ticket_mapping z where x.id = y.LastUpdatedBy and y.id = z.ipim_id and z.ticket_id = ipim_map.ticket_id ) as 'Last Updated User'

from 
IPradar.ipim_ticket_mapping ipim_map,IPim.Tickets ipim
where 

ipim.id = ipim_map.ipim_id
and ipim_map.description like "McKesson Windows Patching%"
#and ipim_map.description not like "%Verify Patches Installed%"
#and ipim_map.description not like "%Pre-Patch Notification%"
and ipim_map.description not like "%Ticket for Daily Reporting%"
#and ipim_map.description not like "%Sameday-patch%"
and ipim_map.description not like "%Update Maintenance Date%"
#and ipim_map.description not like "%Failure to Patch%"
and ipim_map.creation_date >= "2016-11-04 15:00:00"
order by ipim_map.creation_date