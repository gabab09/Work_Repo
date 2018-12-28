select 
auto.name,
exec_st.execution_id,
exec_st.command_description,
exec_st.host,
DATE_FORMAT(DATE_SUB(exec_st.started,INTERVAL 4 HOUR),'%d') as 'Date',
DATE_FORMAT(DATE_SUB(exec_st.started,INTERVAL 4 HOUR),'%H') as 'CreateTimeHour',
DATE_FORMAT(exec_st.started,'%i') as 'CreateTimemin'
from 
IPautomata.state_execution exec_st,IPautomata.automaton auto, IPautomata.execution exec
where
exec_st.execution_id = exec.execution_id
and exec.automaton_id = auto.automaton_id 
and exec_st.started >= "2017-10-04 08:00:00"
and exec_st.finished >= "2017-10-04 08:15:00"
and command_description not in ('Script Action','NOOP','Update Ticket','Success','Form Wait')
and command_description not like ('Timed Wait%')
and command_description not like ('http_request%')
and command_description not like ('Edit Variable:%')
and command_description not like ('Link [%')
and command_description not like ('CMDBAction for name:%')
and command_description not like ('CMDBQuery%')
and command_description not like ('select%')
and command_description not like ('Join [%')
and command_description not like ('Fork [%')
