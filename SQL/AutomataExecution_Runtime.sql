select q.* from 
(select
a.ClientName as 'ClientName',
b.name as 'AutomataName',
count(b.original_id) as 'RunCount',
b.engineer_time_to_diagnose as 'EngineerTimeToDiag',
b.engineer_time_to_remediate as 'EngineerTimeToRem'
from
auth.CLIENT a,
IPautomata.automaton b,
IPautomata.execution e
where
a.ClientID=b.client_id
and b.automaton_id = e.automaton_id 
and a.ClientName = 'McKesson'
and e.created >= '2016-08-01 00:00:00'
and e.creator_id is NULL 
and e.status in ('COMPLETE')  
group by b.name) q
order by q.RunCount desc