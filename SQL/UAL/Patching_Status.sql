select
*
from
(
select 
ci.name as 'CI_Name',
rfc.rfc_id as 'RFC',
rfc.name as 'RFC_Name',
rfc.status as 'RFC_Status',
rfc.closure_code as 'RFC_ClosureCode',
(select txt_data.value from IPcm.text_datum txt_data,IPcm.rfc_attribute rfc_attr,IPcm.rfc cm_rfc where cm_rfc.rfc_id = rfc_attr.rfc_id and rfc_attr.datum_id = txt_data.datum_id and cm_rfc.rfc_id = rfc.rfc_id LIMIT 1) as 'ImpResult',
#auto.name as 'AutomataName',
exec.execution_id as 'ExecutionId',
exec.status as 'Status',
exec.created as 'StartTime',
exec.finished as 'EndTime',
TIMEDIFF(exec.finished,exec.created ) as 'TimeDifference'
from 
IPcm.rfc rfc,IPcm.workflow cmwf,IPautomata.execution exec,IPradar.rfc_ticket_mapping rfc_rdr,IPautomata.automaton auto, IPcmdb.ci ci,IPcm.rfc_ci rfc_ci
where
rfc.workflow_id = cmwf.workflow_id
and rfc.rfc_id = rfc_rdr.rfc_id
and rfc_rdr.ticket_id = exec.ticket_id
and exec.automaton_id = auto.automaton_id
and rfc.rfc_id = rfc_ci.rfc_id
and rfc_ci.ci_id = ci.ci_id
and rfc.current_version_id is NULL
and auto.name = "Windows Patch - SCCM Wave1"
and cmwf.workflow_id = 1
and rfc.created >= "2017-05-12 05:00:00"
and rfc.status != "DRAFT"
)patching
#where
#patching.Status = "RUNNING"
order by patching.RFC_Status desc

