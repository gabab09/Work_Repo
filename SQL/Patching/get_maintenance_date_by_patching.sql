SET @target_group = "wsais-021.oc.mckesson_Monthly_Patching_Wednesday_November_16_2100-2159";

select 
	distinct orderby_maintenance_date.MaintenanceDate
from
(
select
	groupby_maintenance_date.MaintenanceDate
from
(
select
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Maintenance Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'MaintenanceDate'
from
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where
string_datum.datum_id = ci_attribute.datum_id
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Target Group Name"
and string_datum.value = @target_group

union

select
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Temporary Schedule Date" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'MaintenanceDate'
from
IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci
where
string_datum.datum_id = ci_attribute.datum_id
and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id
and ci_attribute.ci_id = ci.ci_id
and attribute_definition.name = "Temporary Target Group Name"
and string_datum.value = @target_group
) groupby_maintenance_date
	group by groupby_maintenance_date.MaintenanceDate
) orderby_maintenance_date
order by orderby_maintenance_date.MaintenanceDate
LIMIT 1