SELECT
cli.ClientName,
auto.NAME AS 'AutomataName',
auto.original_id AS 'ID',
auto.modified 'ModifiedDate',
(SELECT COUNT(1) FROM IPautomata.execution exec, IPautomata.automaton auto_sub WHERE exec.automaton_id =  auto_sub.automaton_id AND auto_sub.original_id = auto.original_id AND exec.created >= (DATE_SUB(NOW(), INTERVAL 30 DAY))) AS 'ExecutionCount',
auto.purpose AS 'Purpose'

FROM
IPautomata.automaton auto, auth.CLIENT cli
WHERE
auto.client_id = cli.ClientID
AND auto.is_live = 1
AND auto.is_archived = 0
AND auto.approval_status = 'APPROVED'
AND cli.ClientName != 'IPsoft, Inc.'
