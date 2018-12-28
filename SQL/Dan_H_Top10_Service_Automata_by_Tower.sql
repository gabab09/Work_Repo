select

all_out.*

from 

(SELECT 
    tr.ticket_id,
    (SELECT
        count(e.success)
    FROM
        IPautomata.execution e
    WHERE
        e.ticket_id = tr.ticket_id
            AND e.status = 'COMPLETE'
            AND e.purpose = 'REMEDIATION'
            AND success = 1
    ) as 'AR',
    (SELECT
        count(e.success)
    FROM
        IPautomata.execution e
    WHERE
        e.ticket_id = tr.ticket_id
            AND e.status = 'COMPLETE'
            AND e.purpose = 'DIAGNOSIS'
            AND success = 1
    ) as 'AD',    
    ti.ipim_id,
    tr.master_ticket_id,
    CONCAT(al.FirstName,' ', al.LastName) as 'Owner',
    cl.ClientClientName as 'ClientName',
    tr.note,
#    tm.service,
    tm.subservice,
    tm.additional_info,
    tm.host_name,
#    tm.alert_type,
    tr.create_date,
    tr.resolve_date,
	dept.name,
	tm.alert_type,
	tm.service,
	(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "OS Type" and w.ticket_id = tr.ticket_id LIMIT 1) as 'OSType',
	(select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPradar.ipcmdb_ticket_mapping w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and y.ci_id = w.ci_id and x.name = "Type" and w.ticket_id = tr.ticket_id LIMIT 1) as 'Type'
FROM
    IPslr.ticket_summary ts
        INNER JOIN
    IPradar.tickets_resolved tr ON (ts.ticket_id = tr.ticket_id)
        LEFT JOIN 
    IPradar.ipim_ticket_mapping ti ON (ti.ticket_id = tr.ticket_id)    
        INNER JOIN
    IPradar.ipmon_ticket_mapping tm ON (tm.ticket_id = tr.ticket_id)
        INNER JOIN 
    auth.CLIENT cl on (cl.ClientID = tr.client_id)
        LEFT JOIN 
    auth.LOGIN al on (al.LoginID = tr.owner_id)
       LEFT JOIN
    auth.DEPARTMENT dept on (dept.departmentID = tr.department_id)
WHERE
    tr.resolve_date > '2016-09-01 00:00:00'
        AND tr.resolve_date < '2016-12-31 23:59:59'
        AND tr.master_ticket_id is null
        #AND dept.name like '%##dept_name##%'
        AND tr.owner_id is not null
        AND tr.note NOT LIKE '%-PaaS%'
) all_out
where 
all_out.OSType is not NULL and all_out.OSType != 'Unix' and all_out.OSType != 'Windows' and all_out.OSType != 'Linux' and all_out.OSType != 'AIX' and all_out.OSType != 'VMware' and all_out.OSType != 'Other' and all_out.OSType != 'Solaris'

