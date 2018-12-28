select 
automata_exec.AutomataID,
automata_exec.AutomataName,
automata_exec.ExecutionCount,
automata_exec.LinkCount,
automata_exec.ExecutionMode,
if ((automata_exec.LinkCount > 1),
(select 
count(1)
from
    IPautomata.execution_log el
left join 
    IPautomata.state_execution se on (el.execution_id = se.execution_id)
left join
    IPautomata.state s on (s.state_id = se.state_id )
left join
    IPautomata.state s2 on (s2.state_id = se.state_scope_id)
left join
    IPautomata.execution e on (e.execution_id = el.execution_id)
left join
    IPautomata.automaton a on (a.automaton_id = s.automaton_id)
left join
    IPautomata.automaton a2 on (a2.automaton_id=s2.automaton_id)
where
    el.state_execution_id = se.state_execution_id
and
s.automaton_id = automata_exec.AutomataID
),'0') as 'LinkExecCount',
automata_exec.Submitter
from
(
select 
automata.automaton_id as 'AutomataID',
automata.original_id as 'OrgionalID',
automata.name as 'AutomataName',
automata.approval_notes as 'AutomataNotes',
automata.execution_mode as 'ExecutionMode',
(select concat(authL.FirstName,' ',authL.LastName) from auth.LOGIN authL where authL.LoginID = automata.submitter_id) as 'Submitter',
(select count(1) from IPautomata.execution exec where exec.automaton_id = automata.automaton_id) as 'ExecutionCount',
(select count(1) from IPautomata.link_action link_ack where link_ack.automaton_id = automata.automaton_id) as 'LinkCount',
automata.reviewed as 'ApprovedDate'
from 
IPautomata.automaton automata 
where 
automata.is_live = 1
and automata.is_archived = 0
and automata.submitter_id is not NULL
and automata.approval_status = 'APPROVED'
) automata_exec
where
automata_exec.ExecutionCount <= 30 
and automata_exec.ApprovedDate <= DATE_SUB(NOW(), INTERVAL 50 DAY)





