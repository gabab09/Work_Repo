select
*
from
(
	SELECT
	lvs_client.ClientName,
	(SELECT COUNT(1) FROM IPautomata.automaton auto WHERE auto.client_id = lvs_client.ClientID AND auto.is_live = 1 AND auto.is_archived = 0 AND auto.approval_status = 'APPROVED') AS 'LiveAutomata',
	(SELECT COUNT(1) FROM IPautomata.execution exec, IPautomata.automaton auto WHERE exec.automaton_id = auto.automaton_id and auto.client_id = lvs_client.ClientID AND exec.created >= DATE_SUB(NOW(),INTERVAL 90 DAY)) AS 'AutomataExecution'
	FROM
	(
		SELECT
		cli.ClientName,
		cli.ClientID
		FROM
		auth.CLIENT cli
		WHERE
		cli.EndDate IS NULL
		AND cli.ClientName NOT IN ('IPsoft, Inc.')
	) lvs_client
) summary
#where 
#summary.LiveAutomata = 0
order by summary.LiveAutomata desc,summary.AutomataExecution desc
