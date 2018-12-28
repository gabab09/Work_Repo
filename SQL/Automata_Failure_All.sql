SELECT b.ClientClientname AS 'Client' ,
       d.name AS 'Automata Name' ,
       c.execution_id AS 'Exec Id' ,
       LEFT(s.command_description,150) AS 'command' ,
       s.return_code AS 'failure_returncode' ,
       CASE
           WHEN c.status = 'ABORTED' THEN
                  (SELECT z.description
                   FROM IPautomata.execution_log z
                   WHERE z.execution_id = cc.execution_id
                     AND z.description LIKE ('%Abort%request%by%') LIMIT 1)
           WHEN s.return_code = -503 THEN
                  (SELECT el.description
                   FROM IPautomata.state_execution se
                   INNER JOIN IPautomata.execution_pointer p ON se.execution_pointer_id = p.execution_pointer_id
                   INNER JOIN IPautomata.execution_log el ON el.execution_pointer_id = p.execution_pointer_id
                   WHERE se.state_execution_id = s.state_execution_id
                     AND description LIKE 'Connect failed to%' LIMIT 1 )
           WHEN (LEFT(s.failure_reason,150)) IS NOT NULL THEN (LEFT(s.failure_reason,150))
           ELSE (LEFT(s.stderr,150))
       END AS 'failure_reason' ,
       Replace(Replace(LEFT(s.stdout,150),"<",""),">","") AS 'failure_stdout' ,
       g.name AS 'State Name' ,
       s.host AS 'Host' ,
       c.purpose AS 'Automata Status' ,
       c.status AS 'Automata RUN Status' ,
       c.created AS 'StartTime' ,
       c.finished AS 'EndTime' ,
       c.ticket_id AS 'RadarTicket'
FROM
  (SELECT e.execution_id ,
     (SELECT max(se.state_execution_id) state_execution_id
      FROM IPautomata.state_execution se
      WHERE e.execution_id = se.execution_id) state_execution_id
   FROM IPautomata.execution e
   WHERE e.creator_id IS NULL
     AND e.created >= DATE_SUB(NOW(), INTERVAL 24 HOUR)
     AND e.status NOT IN ('RUNNING',
                          'COMPLETE',
                          'SCHEDULED',
                          'AUTO_ABORTED')) AS cc
INNER JOIN IPautomata.execution c ON cc.execution_id = c.execution_id
INNER JOIN IPautomata.state_execution s ON s.state_execution_id = cc.state_execution_id
INNER JOIN IPautomata.state g ON s.state_id = g.state_id
INNER JOIN IPautomata.automaton d ON c.automaton_id = d.automaton_id
INNER JOIN auth.CLIENT b ON b.ClientID = d.client_id

order by c.finished desc

