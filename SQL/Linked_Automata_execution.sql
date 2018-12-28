select distinct
el.execution_id,
PARENT.name as PARENT,
s2.automaton_id as parent_id,
a2.name as sub_parent_name,
    s.automaton_id as component_id,
    a.name as component_name
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
 left join 
 IPautomata.automaton PARENT on (PARENT.automaton_id=e.automaton_id)
where
    el.state_execution_id = se.state_execution_id
and
s.automaton_id = 870