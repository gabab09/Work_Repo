select
auto.automaton_id,auto.name,host_act.command
from
IPautomata.host_command_action host_act, IPautomata.action act, IPautomata.state auto_state, IPautomata.automaton auto
where
host_act.action_id = act.action_id
and act.state_id = auto_state.state_id
and auto_state.automaton_id = auto.automaton_id
and host_act.command = '/etc/init.d/IPmon restart'
and auto.is_live = 1
and auto.is_archived = 0