select 
ipmon_attr.ticket_id,
ipmon_attr.service,
ci.name
from
IPradar.ipmon_ticket_mapping ipmon_attr, IPcmdb.ci ci, IPcmdb.string_datum string_datum, IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPradar.tickets radar
where
ipmon_attr.host_name = ci.name
and string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and radar.ticket_id = ipmon_attr.ticket_id
and attribute_definition.name = "OS Type"
and string_datum.value in ('AIX','Linux','HP-UX','Solaris','Unix')
and ipmon_attr.service like ('Disk%')
and radar.note NOT REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?'
and radar.create_date > DATE_SUB(NOW(),Interval 3 Month)

union


select 
ipmon_attr.ticket_id,
ipmon_attr.service,
ci.name
from
IPradar.ipmon_ticket_mapping ipmon_attr, IPcmdb.ci ci, IPcmdb.string_datum string_datum, IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPradar.tickets_resolved radar_resolved
where
ipmon_attr.host_name = ci.name
and string_datum.datum_id = ci_attribute.datum_id 
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id 
and ci_attribute.ci_id = ci.ci_id
and radar_resolved.ticket_id = ipmon_attr.ticket_id
and attribute_definition.name = "OS Type"
and string_datum.value in ('AIX','Linux','HP-UX','Solaris','Unix')
and ipmon_attr.service like ('Disk%')
and radar_resolved.note NOT REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?'
and radar_resolved.create_date > DATE_SUB(NOW(),Interval 3 Month)


