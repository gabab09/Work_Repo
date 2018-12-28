select
udci.Name,
udci.IPAddress,
udci.Status,
udci.Tier,
udci.OSType,
udci.SL
from
(
select 
ci.name as 'Name',
ci.ci_id as 'ciid',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Monitored Address" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'IPAddress',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Status" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Status',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Tier" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'Tier',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "OS Type" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'OSType',
(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Service Level" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'SL',
#(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "WSUS" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'WSUS',
(select ci_type.name from IPcmdb.ci_type ci_type where ci_type.ci_type_id = ci.ci_type_id)  as 'CIType'
from 
IPcmdb.ci ci
where
ci.name like "%CS-P010%" OR  ci.name like "%CS-P011%" OR  ci.name like "%DDCA2003%" OR  ci.name like "%DDCD3315%" OR  ci.name like "%DDCESRSPM01%" OR  ci.name like "%DDCW2005%" OR  ci.name like "%DDCW3268%" OR  ci.name like "%DDCW3268_eis%" OR  ci.name like "%DEVPCHOICEWEB1%" OR  ci.name like "%DEVPCHOICEWEB2%" OR  ci.name like "%dsadc-003%" OR  ci.name like "%eashs-014%" OR  ci.name like "%eashs-015%" OR  ci.name like "%isrmepo-010%" OR  ci.name like "%isrmiam-034%" OR  ci.name like "%itam-037%" OR  ci.name like "%itam-040%" OR  ci.name like "%itcc-046%" OR  ci.name like "%itcc-051%" OR  ci.name like "%itcc-053%" OR  ci.name like "%itcc-056%" OR  ci.name like "%itcc-057%" OR  ci.name like "%itds-190%" OR  ci.name like "%itds-197%" OR  ci.name like "%itds-198%" OR  ci.name like "%itds-199%" OR  ci.name like "%itds-200%" OR  ci.name like "%itds-201%" OR  ci.name like "%itds-202%" OR  ci.name like "%itds-203%" OR  ci.name like "%itds-204%" OR  ci.name like "%itds-205%" OR  ci.name like "%itds-206%" OR  ci.name like "%itds-207%" OR  ci.name like "%itds-208%" OR  ci.name like "%itds-209%" OR  ci.name like "%itds-210%" OR  ci.name like "%itds-211%" OR  ci.name like "%itds-212%" OR  ci.name like "%itds-213%" OR  ci.name like "%itds-217%" OR  ci.name like "%itds-218%" OR  ci.name like "%itsie-018%" OR  ci.name like "%mpsa-122%" OR  ci.name like "%mpsa-136%" OR  ci.name like "%mshwf-002%" OR  ci.name like "%mshwf-003%" OR  ci.name like "%mtsbi-014%" OR  ci.name like "%mtsbi-017%" OR  ci.name like "%mtsims-008%" OR  ci.name like "%mts-pc-279%" OR  ci.name like "%NDHAP50055%" OR  ci.name like "%NDHAP50056%" OR  ci.name like "%NDHAP50111%" OR  ci.name like "%NDHAP50112%" OR  ci.name like "%NDHAQ50074%" OR  ci.name like "%NDHAQ50075%" OR  ci.name like "%NDHAZ30044%" OR  ci.name like "%NDHCQ50634%" OR  ci.name like "%NDHDQ50078%" OR  ci.name like "%NDHDZ40077%" OR  ci.name like "%NDHWQ50076%" OR  ci.name like "%NDHWQ50077%" OR  ci.name like "%ocs-1361%" OR  ci.name like "%PNDCDC01%" OR  ci.name like "%pndcdc03%" OR  ci.name like "%PNDCINF01%" OR  ci.name like "%PNDCINF02%" OR  ci.name like "%PNDCINF03%" OR  ci.name like "%pscts-000%" OR  ci.name like "%psoft%" OR  ci.name like "%RCHTZ6500%" OR  ci.name like "%rhc-175%" OR  ci.name like "%rhc-177%" OR  ci.name like "%sap-1101%" OR  ci.name like "%sap-1157%" OR  ci.name like "%sap-1286%" OR  ci.name like "%sap-1287%" OR  ci.name like "%soc-062%" OR  ci.name like "%SOMD8004%"
) udci
where udci.CIType = "Virtual Device"
