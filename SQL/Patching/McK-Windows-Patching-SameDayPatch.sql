select 
samedaypatch_server_list.TargetGroup,samedaypatch_server_list.MaintenanceDate,samedaypatch_server_list.Frequency,samedaypatch_server_list.WSUS 
from 
(select 
ci.name as 'ServerName',
string_datum.value as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Frequency" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Frequency',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "WSUS" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'WSUS',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TemporaryScheduleDate'


from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Maintenance Date" 
and string_datum.value like "%:%-%:%"
and (select DATE(string_datum.value)) >= DATE(NOW())
and (select DATE(string_datum.value)) <= DATE(NOW())
order by string_datum.value) samedaypatch_server_list
where
samedaypatch_server_list.TargetGroup is not NULL
and samedaypatch_server_list.TemporaryScheduleDate is NULL
group by samedaypatch_server_list.TargetGroup,samedaypatch_server_list.MaintenanceDate,samedaypatch_server_list.Frequency,samedaypatch_server_list.WSUS

union 


select 
samedaypatch_temp_server_list.TargetGroup,samedaypatch_temp_server_list.MaintenanceDate,samedaypatch_temp_server_list.Frequency,samedaypatch_temp_server_list.WSUS 
from 
(select 
ci.name as 'ServerName',
string_datum.value as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Frequency" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Frequency',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "WSUS" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'WSUS'

from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Temporary Schedule Date" 
and string_datum.value like "%:%-%:%"
and (select DATE(string_datum.value)) >=  DATE(NOW())
and (select DATE(string_datum.value)) <=  DATE(NOW())
order by string_datum.value) samedaypatch_temp_server_list
where
samedaypatch_temp_server_list.TargetGroup is not NULL
group by samedaypatch_temp_server_list.TargetGroup,samedaypatch_temp_server_list.MaintenanceDate,samedaypatch_temp_server_list.Frequency,samedaypatch_temp_server_list.WSUS
