select 
ci.name as 'CiName',
st_data.value as 'IPaddress',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Status" and y.ci_id = ci.ci_id LIMIT 1) as 'Status',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Tier" and y.ci_id = ci.ci_id LIMIT 1) as 'Tier',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "OS Type" and y.ci_id = ci.ci_id LIMIT 1) as 'OSType',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Service Level" and y.ci_id = ci.ci_id LIMIT 1) as 'SL',
(select ci_type.name from IPcmdb.ci_type ci_type where ci_type.ci_type_id = ci.ci_type_id)  as 'CIType'
from 
IPcmdb.string_datum st_data,
IPcmdb.ci_attribute ci_attr,
IPcmdb.attribute_definition ci_attr_def,
IPcmdb.ci ci 
where 
st_data.datum_id = ci_attr.datum_id and 
ci_attr.attribute_definition_id = ci_attr_def.attribute_definition_id and 
ci_attr_def.name = "Monitored Address" and 
ci_attr.ci_id = ci.ci_id and 
st_data.value in ('10.124.144.148','10.125.66.10','10.124.22.14','10.124.22.15','10.124.22.16','10.125.72.12','10.125.72.13','10.125.72.14','10.125.72.10','10.125.72.11','10.8.190.6','10.5.31.80','10.9.194.15','10.8.190.8','10.5.11.60','10.5.11.4','10.124.42.30','10.124.42.31','10.108.73.17','10.8.179.17','10.8.179.18','10.17.15.10','10.124.118.12','10.8.159.26','10.8.159.29','10.9.191.23','10.125.71.79','10.9.191.25','10.125.71.83','10.125.71.84','10.9.146.35','10.17.34.13','10.17.34.14','10.17.34.15','10.17.34.16','10.125.67.138','10.125.67.139','10.125.67.140','10.125.67.141','10.17.34.11','10.17.34.17','10.17.34.18','10.17.34.19','10.17.34.20','10.125.67.142','10.125.67.143','10.125.67.144','10.125.67.145','10.17.34.23','10.17.34.24','10.17.47.11','10.124.5.62','10.124.5.65','10.124.14.13','10.124.14.14','10.124.100.11','10.124.100.14','10.124.71.14','10.9.143.48','10.124.90.20','10.124.90.21','10.122.55.68','10.122.55.69','10.124.91.5','10.124.91.6','10.124.91.26','10.124.1.30','10.124.91.7','10.124.91.49','10.124.91.8','10.124.91.9','10.124.1.14','67.220.194.133','67.220.194.133','67.220.194.133','67.220.194.133','67.220.194.133','10.124.47.13','67.220.194.133','10.8.170.13','10.9.163.77','10.9.163.86','10.8.210.35','67.220.194.133','10.8.214.19','10.8.214.20','10.124.54.21','172.19.2.47')