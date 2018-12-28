select 
prepatch_server_list.TargetGroup,prepatch_server_list.MaintenanceDate,prepatch_server_list.Frequency,prepatch_server_list.WSUS 
from 
(select 
ci.name as 'ServerName',
string_datum.value as 'MaintenanceDate',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Frequency" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Frequency',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "WSUS" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'WSUS'


from 
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where 
string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Maintenance Date" 
and string_datum.value like "%:%-%:%"
and (select DATE(string_datum.value)) = DATE(DATE_ADD(NOW(), INTERVAL 7 DAY))
order by string_datum.value) prepatch_server_list
where
prepatch_server_list.TargetGroup is not NULL
group by prepatch_server_list.TargetGroup,prepatch_server_list.MaintenanceDate,prepatch_server_list.Frequency,prepatch_server_list.WSUS
