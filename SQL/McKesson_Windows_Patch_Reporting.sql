select
windowspatching.ClientName,
windowspatching.ServerName,
windowspatching.CIID,
windowspatching.CIType,
windowspatching.MaintenanceDate,
windowspatching.TargetGroup,
#windowspatching.NewMaintenanceDate,
#windowspatching.NewTargetGroup,
windowspatching.PatchingCurrentStatus,
windowspatching.PatchingLastStatus,
windowspatching.PatchingStatusLastUpdate,
windowspatching.BackupStatus,
windowspatching.Status,
windowspatching.IPsoftManaged,
windowspatching.Monitored,
windowspatching.TempSchedule,
windowspatching.TempTarget,
windowspatching.SL,
windowspatching.EmailAddress,
windowspatching.AdditionalEmailAddress,
windowspatching.WSUS,
#windowspatching.PatchingStatus
windowspatching.LastHostReboot,
windowspatching.LastPatchInstalledDate,
windowspatching.MissingPatches


from 
(
select
(select client.ClientClientname from auth.CLIENT client where client.ClientID = ci.client_id) as 'ClientName',
ci.name as 'ServerName',
ci.ci_id as 'CIID',
(select ci_type.name from IPcmdb.ci_type ci_type where ci_type.ci_type_id = ci.ci_type_id)  as 'CIType',
string_datum.value as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup',
#(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Maintenance Start" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'NewMaintenanceDate',
#(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Maintenance End" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'NewTargetGroup',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Patching Current Status" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'PatchingCurrentStatus',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Patching Last Status" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'PatchingLastStatus',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Patching Status Last Update" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'PatchingStatusLastUpdate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Job Status" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'BackupStatus',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Status" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Status',
case 
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "IPsoft Managed" and w.name = ci.name LIMIT 1) = 1
then ('True')
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "IPsoft Managed" and w.name = ci.name LIMIT 1) = 0
then ('False')
else ('NA')
end as 'IPsoftManaged',
case 
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Monitored" and w.name = ci.name LIMIT 1) = 1
then ('True')
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Monitored" and w.name = ci.name LIMIT 1) = 0
then ('False')
else ('NA')
end as 'Monitored',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Patching" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'PatchingStatus',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TempSchedule',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TempTarget',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Service Level" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'SL',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'EmailAddress',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Additional Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'AdditionalEmailAddress',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "WSUS" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'WSUS',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Last Host Reboot" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'LastHostReboot',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Last Patch Installed Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'LastPatchInstalledDate',
(select z.value from IPcmdb.text_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Missing Patches" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'MissingPatches'

from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Maintenance Date" 
and string_datum.value like "%:%-%:%"
#and (select DATE(string_datum.value)) >= "2016-09-27 00:00:00"
#and ci.name not like ('decommissioned%')
order by string_datum.value
) windowspatching
where 
windowspatching.Status != "Decommissioned"  
and windowspatching.PatchingCurrentStatus is NOT NULL
and windowspatching.MaintenanceDate >= "2017-12-01 23:59:59"
#and windowspatching.MaintenanceDate <= "2017-11-13 00:00:00"
and windowspatching.ClientName = 'McKesson'
#and windowspatching.SL = "SL0"
#and windowspatching.PatchingCurrentStatus in ('PATCH_SCHEDULED')
#and windowspatching.ClientName = 'Celesio'
#and windowspatching.PatchingCurrentStatus not in ('DOWNLOAD_APPROVED_PATCHES')
#and windowspatching.PatchingCurrentStatus in ('SCHEDULED_FOR_PREPATCH_USER_NOTIFICATION')
#and (windowspatching.TargetGroup like "undefined_%" or windowspatching.TargetGroup like "TBD_%")
#and windowspatching.LastHostReboot is not NULL

