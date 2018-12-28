
SELECT DISTINCT 
  x.ci_name,
  x.ci_created,
  x.ci_updated,
  x.ci_type, 
  x.ci_contact_group,
  x.ip_address,
  x.ipcmdb_status, 
  x.ipadmin_status, 
  x.sc_count, 
  CASE 
  WHEN x.ipcmdb_status = 'Is Monitored' AND x.ipadmin_status = 'Is Monitored' AND x.sc_count > 1 
    THEN 'OK' 
  WHEN x.ipcmdb_status = 'Is Monitored' AND x.ipadmin_status = 'Is Monitored' AND x.sc_count <= 1 
    THEN 'Only 1 or 0 checks configured' 
  WHEN x.ipcmdb_status = 'Is Monitored' AND x.ipadmin_status = 'Not Monitored' 
    THEN 'CI marked for monitoring but not monitored in IPadmin' 
  WHEN x.ipcmdb_status = 'Not Monitored' AND x.ipadmin_status = 'Is Monitored' 
    THEN 'CI not marked for monitoring but is currently monitored in IPadmin' 
  WHEN x.ipcmdb_status = 'Not Monitored' AND x.ipadmin_status = 'Not Monitored' 
    THEN 'CI not monitored' 
  ELSE 'Unknown configuration' 
  END AS monitoring_status 
FROM ( 
       SELECT 
         ci.name                                                   AS ci_name,
			ci.created 				AS ci_created,
			ci.updated 				AS ci_updated, 
         cit.name                                                  AS ci_type, 
         cicg.name											  	   AS ci_contact_group,
         ip.value												   AS ip_address,
         IF(bd.value = 1, 'Is Monitored', 'Not Monitored')         AS ipcmdb_status, 
         IF(h.deletedate IS NULL, 'Not Monitored', 'Is Monitored') AS ipadmin_status, 
         IF(sc.deletedate IS NULL, 0, count(1))                    AS sc_count 
       FROM IPcmdb.ci AS ci 
         JOIN auth.CLIENT AS cl ON cl.ClientID = ci.client_id 
         JOIN IPcmdb.ci_type AS cit ON (ci.ci_type_id = cit.ci_type_id) 
         LEFT JOIN IPcmdb.ci_attribute AS cia ON (ci.ci_id = cia.ci_id) 
         LEFT JOIN IPcmdb.attribute_definition AS ad ON (ad.attribute_definition_id = cia.attribute_definition_id)
         LEFT JOIN IPcmdb.ci_association cias on cias.source_ci_id = ci.ci_id
		 LEFT JOIN IPcmdb.ci cicg on cicg.ci_id = (select cias.source_ci_id from IPcmdb.ci_association cias where cias.target_ci_id=ci.ci_id and cias.association_type_id =
			(select at.association_type_id from IPcmdb.association_type at where at.target_role_description = 'Contact Groups') limit 1)  
		 LEFT JOIN IPcmdb.string_datum stat on stat.datum_id = (select att.datum_id from IPcmdb.ci_attribute att where  att.ci_id=ci.ci_id and att.attribute_definition_id =
			(select defid.attribute_definition_id from IPcmdb.attribute_definition defid where defid.name='Status' ) limit 1) 
		 LEFT JOIN IPcmdb.string_datum ip on ip.datum_id = (select att.datum_id from IPcmdb.ci_attribute att where  att.ci_id=ci.ci_id and att.attribute_definition_id =
			(select defid.attribute_definition_id from IPcmdb.attribute_definition defid where defid.name='Monitored Address' ) limit 1) 
		 LEFT JOIN IPcmdb.boolean_datum AS bd ON (bd.datum_id = cia.datum_id) 
         LEFT JOIN IPadmin.host AS h ON (ci.name = h.name AND h.deleteDate = date_format('1970-01-01', '%Y-%m-%d')) 
         LEFT JOIN IPadmin.serviceCheck AS sc 
           ON (sc.hostID = h.baseCheckID AND sc.deleteDate = date_format('1970-01-01', '%Y-%m-%d')) 
       WHERE 
         cit.name IN ('Device', 'Virtual Device', 'Application Instance', 'Generic Database Instance', 'Oracle Database Instance') AND 
         ad.name = 'Monitored' AND
         stat.value = 'Active' AND
         cl.ClientName = 'McKesson'
		 GROUP BY ci.name 
       ORDER BY   h.deleteDate DESC, 
         ci.name ASC 
     ) x 
ORDER BY monitoring_status
