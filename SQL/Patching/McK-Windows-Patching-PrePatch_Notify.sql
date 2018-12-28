set @date_patching = "2017-03-23";

select 
list_target_group.ServerName,
list_target_group.MaintenanceDate,
list_target_group.TargetGroup,
(select exec.execution_id from IPautomata.execution exec,IPautomata.automaton automaton,IPautomata.execution_variable exec_var where exec.automaton_id = automaton.automaton_id and exec.execution_id = exec_var.execution_id and automaton.name = "Approve Patches by Target Group - Version 3" and automaton.approval_status = "APPROVED" and exec.status = "COMPLETE" and exec_var.name = "target_group"  and exec_var.value = list_target_group.TargetGroup and exec.created >= DATE_SUB(NOW(), Interval 11 DAY) order by exec.execution_id desc LIMIT 1) as 'ApprovePatchExecid-Phase1',
(select exec.execution_id from IPautomata.execution exec,IPautomata.automaton automaton,IPautomata.execution_variable exec_var where exec.automaton_id = automaton.automaton_id and exec.execution_id = exec_var.execution_id and automaton.name = "Prepatch_ApprovePatches_By_TargetGroup" and exec.status = "COMPLETE" and exec_var.name = "target_group"  and exec_var.value = list_target_group.TargetGroup and exec.created >= DATE_SUB(NOW(), Interval 11 DAY) order by exec.execution_id desc LIMIT 1) as 'ApprovePatchExecid-Phase2'
from
(select 
ci.name as 'ServerName',
string_datum.value as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup',
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
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TempSchedule',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TempTarget',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Service Level" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'SL'
from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Maintenance Date" 
and string_datum.value like "%:%-%:%"
and (select DATE(string_datum.value)) = @date_patching
and ci.name not like ('decommissioned%')
order by string_datum.value) list_target_group
