select 
c.name as 'CI Name',
e.name as 'CI Type',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "Type" Limit 1) as 'Type',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "OS Type" LIMIT 1) as 'OS Type',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "OS Sub-Type" LIMIT 1) as 'OS Sub-Type',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "Status" LIMIT 1) as 'Status',
case 
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "IPsoft Managed") = 1
then ('True')
else ('False')
end as 'IPsoft Managed',
case
when (select z.value from IPcmdb.boolean_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = b.ci_id and x.name = "Monitored") = 1
then ('True')
else ('False')
end as 'Monitored',
(select count(1) from IPradar.ipmon_ticket_mapping x where x.host_name = c.name and date >= "2016-06-01 00:00:00" LIMIT 1) as 'Alert Count'


from

IPcmdb.ci_attribute b,
IPcmdb.ci c,
IPcmdb.ci_type e

where
b.ci_id = c.ci_id
and c.ci_type_id = e.ci_type_id
and ((e.name like "%Device%") OR (e.name like "%Database%"))
