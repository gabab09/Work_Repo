SET @target_group = "wsais-020.oc.mckesson_Monthly_Patching_Wednesday_November_23_1900-1959";
SET @interval_st = "5";
SET @interval_ed = "0";

select 
case 
when 
(select 
exec.execution_id as 'Execution'
from
IPautomata.execution exec,IPautomata.automaton automaton,IPautomata.execution_variable exec_var
where 
exec.automaton_id = automaton.automaton_id
and exec.execution_id = exec_var.execution_id
and automaton.name = "Approve Patches by Target Group - Version 3"
and automaton.approval_status = "APPROVED"
and exec.status = "COMPLETE"
and exec_var.name = "target_group"
and exec_var.value = (select IF(LOCATE('Temp_',@target_group),(select (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup' from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and ci_attribute.ci_id = ci.ci_id and attribute_definition.name = "Temporary Target Group Name"  and string_datum.value = @target_group LIMIT 1),@target_group ))
and exec.created >= DATE_SUB(NOW(), Interval @interval_st DAY)
and exec.created <= DATE_SUB(NOW(), Interval @interval_ed DAY)
order by exec.execution_id desc
LIMIT 1)  is not NULL
then
(select 
exec.execution_id as 'Execution'
from
IPautomata.execution exec,IPautomata.automaton automaton,IPautomata.execution_variable exec_var
where 
exec.automaton_id = automaton.automaton_id
and exec.execution_id = exec_var.execution_id
and automaton.name = "Approve Patches by Target Group - Version 3"
and automaton.approval_status = "APPROVED"
and exec.status = "COMPLETE"
and exec_var.name = "target_group"
and exec_var.value = (select IF(LOCATE('Temp_',@target_group),(select (select z.value from IPcmdb.string_datum z,IPcmdb.ci_attribute y,IPcmdb.attribute_definition x,IPcmdb.ci w where z.datum_id = y.datum_id and y.attribute_definition_id = x.attribute_definition_id and x.name = "Target Group Name" and y.ci_id = w.ci_id and w.name = ci.name LIMIT 1) as 'TargetGroup' from IPcmdb.string_datum string_datum,IPcmdb.ci_attribute ci_attribute,IPcmdb.attribute_definition attribute_definition, IPcmdb.ci ci where string_datum.datum_id = ci_attribute.datum_id and ci_attribute.attribute_definition_id = attribute_definition.attribute_definition_id and ci_attribute.ci_id = ci.ci_id and attribute_definition.name = "Temporary Target Group Name"  and string_datum.value = @target_group LIMIT 1),@target_group ))
and exec.created >= DATE_SUB(NOW(), Interval @interval_st DAY)
and exec.created <= DATE_SUB(NOW(), Interval @interval_ed DAY)
order by exec.execution_id desc
LIMIT 1)
else "NOEXECUTION"
end as "ExecutionID"