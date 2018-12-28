select 
cmdb_tkt_map.ticket_id as 'RadarTkt',
cmdb_tkt_map.name as 'CIName',
cmdb_tkt_map.creation_date as 'Date',
ta.value as 'ST'
from
IPradar.ipcmdb_ticket_mapping cmdb_tkt_map
Left Join IPradar.ticket_attribute ta on cmdb_tkt_map.ticket_id = ta.ticket_id
where 
cmdb_tkt_map.creation_date >= "2016-12-01 00:00:00"
and ta.name = 'support_tier'
and cmdb_tkt_map.name in 

(select 
#client.ClientClientname as 'client',
ci_tar.name as 'ci_name'
#ci.name as 'contact_group'
#ci.ci_id

from 
IPcmdb.ci_type ci_type
Inner Join IPcmdb.ci ci on ci_type.ci_type_id = ci.ci_type_id
Inner join IPcmdb.ci_association ci_ass on ci.ci_id = ci_ass.source_ci_id
Inner join IPcmdb.ci ci_tar on ci_ass.target_ci_id = ci_tar.ci_id
Inner Join auth.CLIENT client on ci_tar.client_id = client.ClientID
where
ci_type.name = 'Contact Group'
and (ci.name like ('%series%') OR ci.name like ('%P7%'))

union 

select 
#client.ClientClientname as 'client',
ci.name as 'ci_name'
from 
IPcmdb.attribute_definition attr_def
Inner Join IPcmdb.ci_attribute ci_attr on attr_def.attribute_definition_id = ci_attr.attribute_definition_id
Inner Join IPcmdb.ci ci on ci_attr.ci_id = ci.ci_id
Inner Join IPcmdb.string_datum str_data on str_data.datum_id = ci_attr.datum_id
Inner Join auth.CLIENT client on ci.client_id = client.ClientID
where
attr_def.name = "OS Type"
and str_data.value = "I5/OS"
)
