select group_concat(string_datum.value) as 'ipwin_servers'
from 
IPcmdb.ci source_ci
inner join IPcmdb.ci_attribute ci_attribute on ci_attribute.ci_id = source_ci.ci_id
inner join IPcmdb.attribute_definition attribute_definition on attribute_definition.attribute_definition_id = ci_attribute.attribute_definition_id
inner join IPcmdb.string_datum string_datum on string_datum.datum_id = ci_attribute.datum_id
where 
attribute_definition.name = 'IP Address'
and source_ci.ci_id in (select ci_association.source_ci_id from IPcmdb.ci ci , IPcmdb.ci_association ci_association where ci.ci_id = ci_association.target_ci_id and ci.name = 'ipmon32.prod-ddc.mckesson.ipsoft.com')

