select 
automaton.name as 'AutomataName',
automaton.automaton_id as 'AutomataId',
state.name as 'StateName',
wait_matcher.pattern as 'Pattern'
from 
IPautomata.ticket_event_wait_matcher wait_matcher
#Left join IPautomata.ticket_event_wait_action wait_action on wait_matcher.action_id = wait_action.action_id
#Left join IPautomata.action action on wait_action.action_id = action.action_id
Left join IPautomata.action action on wait_matcher.action_id = action.action_id
Inner join IPautomata.state state on action.state_id = state.state_id
Inner join IPautomata.automaton automaton on state.automaton_id = automaton.automaton_id
where 
wait_matcher.pattern in ('ipautomata','(?i)ipautomata','!ipautomata')
and automaton.is_live = 1
and automaton.is_archived = 0