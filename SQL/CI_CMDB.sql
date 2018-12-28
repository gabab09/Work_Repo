select
*
from
(
select
(select client.ClientClientname from auth.CLIENT client where client.ClientID = ci.client_id) as 'ClientName',
ci.name as 'ServerName',
ci_type.name as 'CIType',
string_datum_status.value as 'Status',
case
when (select sub_boolean_datum.value from IPcmdb.boolean_datum sub_boolean_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_boolean_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "IPsoft Managed" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) = 1
then ('True')
when (select sub_boolean_datum.value from IPcmdb.boolean_datum sub_boolean_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_boolean_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "IPsoft Managed" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) = 0
then ('False')
else ('NA')
end as 'IPsoftManaged',
case
when (select sub_boolean_datum.value from IPcmdb.boolean_datum sub_boolean_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_boolean_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Monitored" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) = 1
then ('True')
when (select sub_boolean_datum.value from IPcmdb.boolean_datum sub_boolean_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_boolean_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Monitored" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) = 0
then ('False')
else ('NA')
end as 'Monitored',

(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "OS Type" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'OSType',
#(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Service Level" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'ServiceLevel',
#(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Type" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'Type',
(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Tier" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'Tier',
(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Monitored Address" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'Monitored_Address'
#(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Business Unit" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'Business_Unit',
#(select sub_string_datum.value from IPcmdb.string_datum sub_string_datum,IPcmdb.ci_attribute sub_ci_attr,IPcmdb.attribute_definition sub_attr_def where sub_string_datum.datum_id = sub_ci_attr.datum_id and sub_ci_attr.attribute_definition_id = sub_attr_def.attribute_definition_id and sub_attr_def.name = "Domain" and sub_ci_attr.ci_id = ci.ci_id LIMIT 1) as 'Domain'


from
IPcmdb.ci ci,IPcmdb.string_datum string_datum_status,IPcmdb.ci_attribute ci_attribute_status,IPcmdb.attribute_definition attribute_definition_status,IPcmdb.ci_type ci_type
where
string_datum_status.datum_id = ci_attribute_status.datum_id
and ci_attribute_status.attribute_definition_id = attribute_definition_status.attribute_definition_id
and ci_attribute_status.ci_id = ci.ci_id
and ci_type.ci_type_id = ci.ci_type_id

and attribute_definition_status.name = "Status"
and string_datum_status.value = "Active"
and ci_type.name in ('Device','Virtual Device')
and ci.client_id in ('18','20')
order by ci.name
) cmdb_dump
#where
#cmdb_dump.OSType not in ('IOS','Commware','SAN/NAS','CatOS','Cisco ACE','Cisco ASA','CTS','EMC Flare','JunS','Network','NTAP','NX-OS','VMware')
order by cmdb_dump.OSType