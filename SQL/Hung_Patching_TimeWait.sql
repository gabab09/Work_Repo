select 
#c.ClientClientname,
b.name as "AutomataName",
a.ticket_id as "R-Tkt",
a.execution_id as "Exection",
a.status as "Status",
a.created as "Exec_Started",
d.command_description as "Command",
d.started as "Exec_State_Started",
UTC_TIMESTAMP() as "UTC_Time",
MINUTE((TIME_TO_SEC(TIMEDIFF(UTC_TIMESTAMP(),d.started)))) as 'DifferenceInMins'
from
IPautomata.execution a,IPautomata.automaton b,auth.CLIENT c,IPautomata.state_execution d
where
a.automaton_id = b.automaton_id
and b.client_id = c.ClientID
and d.execution_id = a.execution_id
and a.status in ('SCHEDULED','READY','RUNNING' )
and d.state_execution_id = (select max(state_execution_id) from IPautomata.state_execution where execution_id=a.execution_id)
and a.created >= "2017-03-24 00:00:00"
and d.command_description like ('%Timed%Wait%seconds%')
and MINUTE((TIME_TO_SEC(TIMEDIFF(UTC_TIMESTAMP(),d.started)))) is NOT NULL
order by MINUTE((TIME_TO_SEC(TIMEDIFF(UTC_TIMESTAMP(),d.started)))) desc
