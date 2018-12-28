select
*
from
(select
ci.name as 'Name',
ci_st_data.value as 'Status',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Maintenance Date" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'Maintenance Date',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "OS Type" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'OSType',
(select sub_std.value from IPcmdb.boolean_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Patching" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'Patching',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Target Group Name" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'TargetGroupName',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "P/DNR" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'PDNR',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Frequency" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'Frequency',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "WSUS" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'WSUS',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Patching Current Status" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'PatchingCurrentStatus',
(select sub_std.value from IPcmdb.text_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Environment Specification" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'EnvironmentSpecification',
(select sub_std.value from IPcmdb.string_datum sub_std,IPcmdb.ci_attribute sub_attr,IPcmdb.attribute_definition sub_attrdef where sub_std.datum_id = sub_attr.datum_id and sub_attr.attribute_definition_id = sub_attrdef.attribute_definition_id and sub_attrdef.name = "Service Level" and sub_attr.ci_id = ci.ci_id LIMIT 1) as 'ServiceLevel'
from
IPcmdb.ci ci, IPcmdb.ci_type ci_type, IPcmdb.string_datum ci_st_data, IPcmdb.ci_attribute ci_attribute ,IPcmdb.attribute_definition ci_attr_def
where
ci.ci_type_id = ci_type.ci_type_id
and ci_st_data.datum_id = ci_attribute.datum_id
and ci_attribute.attribute_definition_id = ci_attr_def.attribute_definition_id
and ci.ci_id = ci_attribute.ci_id
and ci_attr_def.name = "Status"
#and ci_st_data.value = "Active"
and ci.name not like ('decommissioned-%')
and ci.name not like ('decommissioned.%')
and ci_type.name like "%Device"
) cmdb
where
cmdb.OSType like ('%window%')
