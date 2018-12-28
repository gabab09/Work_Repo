
select 
samedaypatch_server_list.ContactList,samedaypatch_server_list.MaintenanceDate,samedaypatch_server_list.ServerName
from 
(select 
(select CONCAT((select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1),',',(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Additional Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1))) as 'ContactList',
ci.name as 'ServerName',
string_datum.value as 'TargetGroupName',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Maintenance Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TemporaryScheduleDate'

from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 

string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Target Group Name" 
and string_datum.value = "$target_group"
order by string_datum.value) samedaypatch_server_list
where
samedaypatch_server_list.TemporaryScheduleDate is NULL
and (select DATE(samedaypatch_server_list.MaintenanceDate)) =  DATE(NOW())
group by samedaypatch_server_list.MaintenanceDate,samedaypatch_server_list.ServerName

union

select 
samedaypatch_temp_server_list.ContactList,samedaypatch_temp_server_list.MaintenanceDate,samedaypatch_temp_server_list.ServerName
from 
(select 
(select CONCAT((select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1),',',(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Additional Email Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1))) as 'ContactList',
ci.name as 'ServerName',
string_datum.value as 'TargetGroupName',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'MaintenanceDate'
from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Temporary Target Group Name" 
and string_datum.value = "$target_group"
order by string_datum.value) samedaypatch_temp_server_list
where
(select DATE(samedaypatch_temp_server_list.MaintenanceDate)) = DATE(NOW())
group by samedaypatch_temp_server_list.MaintenanceDate,samedaypatch_temp_server_list.ServerName
