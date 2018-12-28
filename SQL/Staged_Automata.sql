select 
auto.automaton_id as 'AutomationID',
auto.name as 'AutomataName',
#auto.approval_status 'AutomataStatus',
(select CONCAT(auth.FirstName,' ',auth.LastName) from auth.LOGIN auth where auth.LoginID = auto.creator_id) as 'CreatorName',
(select CONCAT(auth.FirstName,' ',auth.LastName) from auth.LOGIN auth where auth.LoginID = auto.editor_id) as 'EditorName'
#(select count(1) from IPautomata.execution exec where exec.automaton_id = auto.automaton_id and auto.automaton_id=auto.original_id) as 'ExecCount'
from 

IPautomata.automaton auto,IPautomata.ticket_matcher tktm,IPautomata.automaton auto1

where 
auto.automaton_id = tktm.automaton_id
and auto.original_id = auto1.original_id
and auto.approval_status like ('%NONE%')
and auto.is_archived != 1
and auto.client_id != 17
#and auto1.approval_status like ('%APPROVED%')
#and auto.created >= "2016-07-01 00:00:00"
group by auto.name,(select CONCAT(auth.FirstName,' ',auth.LastName) from auth.LOGIN auth where auth.LoginID = auto.creator_id) 
