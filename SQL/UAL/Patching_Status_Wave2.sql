
SET @execution_date = "2017-07-17 02:30:00";
SET @rfc_create_date = "2017-07-14 00:00:00";

select
patching.CI_Name,
patching.RFC,
patching.ExecutionId,
patching.PatchLastResult,
patching.PatchStatus,
patching.PatchUpdatedTime,
patching.RFC_Name,
patching.RFC_Status,
patching.RFC_ClosureCode,
patching.AutomataStatus,
patching.Running_Duration_In_Mins,
patching.AutomataStTime,
patching.AutomataEndTime,
patching.Duration_In_Mins,
patching.ci_ipmon,
patching.ci_ipwin
from
(
	select
	rfc_cmdb.CI_Name,
	rfc_cmdb.RFC,
	rfc_cmdb.ExecutionId,
	rfc_cmdb.PatchLastResult,
	rfc_cmdb.PatchStatus,
	rfc_cmdb.PatchUpdatedTime,
	rfc_cmdb.RFC_Name,
	rfc_cmdb.RFC_Status,
	rfc_cmdb.RFC_ClosureCode,
	(select exec.status from IPautomata.execution exec where exec.execution_id = rfc_cmdb.ExecutionId and exec.created >= @execution_date ) as 'AutomataStatus',
	(select exec.created from IPautomata.execution exec where exec.execution_id = rfc_cmdb.ExecutionId  and exec.created >= @execution_date ) as 'AutomataStTime',
	(select exec.finished from IPautomata.execution exec where exec.execution_id = rfc_cmdb.ExecutionId and exec.created >= @execution_date ) as 'AutomataEndTime',
		(select exec_var.value from IPautomata.execution_variable exec_var where exec_var.execution_id = rfc_cmdb.ExecutionId and exec_var.name = "ci_ipmon" ) as 'ci_ipmon',
		(select exec_var.value from IPautomata.execution_variable exec_var where exec_var.execution_id = rfc_cmdb.ExecutionId and exec_var.name = "ci_ipmon" ) as 'ci_ipwin',
	(select ROUND(time_to_sec((TIMEDIFF (exec.finished,exec.created))) / 60) from IPautomata.execution exec where exec.execution_id = rfc_cmdb.ExecutionId and exec.created >= @execution_date ) as 'Duration_In_Mins',
	(select ROUND(time_to_sec((TIMEDIFF (NOW(),exec.created))) / 60) from IPautomata.execution exec where exec.execution_id = rfc_cmdb.ExecutionId and exec.created >= @execution_date ) as 'Running_Duration_In_Mins'
	from
		(
		select 
		ci.name as 'CI_Name',
		rfc.rfc_id as 'RFC',
		(select string_datum.value from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and attribute_definition.name = "WPatchExecutionId" and ci_attribute.ci_id = ci.ci_id LIMIT 1) as 'ExecutionId',
		(select string_datum.value from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and attribute_definition.name = "WPatchLastResult" and ci_attribute.ci_id = ci.ci_id LIMIT 1) as 'PatchLastResult',
		(select string_datum.value from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and attribute_definition.name = "WPatchStatus" and ci_attribute.ci_id = ci.ci_id LIMIT 1) as 'PatchStatus',
		(select string_datum.value from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and attribute_definition.name = "WPatchUpdatedText" and ci_attribute.ci_id = ci.ci_id LIMIT 1) as 'PatchUpdatedTime',
		rfc.name as 'RFC_Name',
		rfc.status as 'RFC_Status',
		rfc.closure_code as 'RFC_ClosureCode',
		rfc.implementation_date as 'implementation_date'

		from 
			IPcm.rfc rfc,IPcm.workflow cmwf, IPcmdb.ci ci,IPcm.rfc_ci rfc_ci
		where
			rfc.workflow_id = cmwf.workflow_id
			and rfc.rfc_id = rfc_ci.rfc_id
			and rfc_ci.ci_id = ci.ci_id
			and rfc.current_version_id is NULL
			and cmwf.workflow_id = 3
			and rfc.created >= @rfc_create_date
			and rfc.status not in ('DRAFT','FAILED')
		) rfc_cmdb
) patching
where
patching.RFC in ('2908') 
and patching.AutomataStTime is not NULL
and patching.AutomataStatus != 'RUNNING'
#and patching.PatchLastResult like 'ERROR-%'
#and patching.Duration_In_Mins > 5
#and patching.PatchLastResult not like '%failed%'
#and patching.PatchLastResult like '%success%'
order by patching.AutomataStatus desc, patching.AutomataStTime desc
