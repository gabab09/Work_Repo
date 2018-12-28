SELECT
org_auto.NAME,
COUNT(org_auto.NAME) AS 'RunCount'
#exec.execution_id,
#exec.created

FROM
IPautomata.automaton auto,IPautomata.execution exec, IPautomata.automaton org_auto
WHERE
auto.automaton_id = exec.automaton_id
and auto.original_id = org_auto.original_id
and org_auto.is_live = 1
and org_auto.is_archived = 0
AND org_auto.approval_status = 'APPROVED'
AND exec.created >= '2018-10-10 00:00:00'
#and auto.NAME LIKE ('%HRIS%')
GROUP BY org_auto.NAME
