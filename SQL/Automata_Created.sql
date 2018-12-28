select
*
from
(
select 
#auto.original_id as 'OrgionalId',
(select y.ClientClientname from auth.CLIENT y where y.ClientID = auto.client_id) as 'ClientName',
auto.name as 'AutomataName',
auto.notes as 'Description',
(select concat(login.FirstName,login.LastName) from auth.LOGIN login where login.LoginID = auto.creator_id) as 'Creator',
(select dept.Name from auth.LOGIN login, auth.INTERNAL_LOGIN internal_login, auth.DEPARTMENT dept where  login.LoginID = internal_login.LoginID and internal_login.DepartmentID = dept.DepartmentID and login.LoginID = auto.creator_id) as 'Department',
(select count(1) from IPautomata.execution exec,IPautomata.automaton auto_sub where exec.automaton_id = auto_sub.automaton_id and auto_sub.original_id = auto.original_id and exec.created >= "2017-03-01 00:00:00") as 'ExecutionCount',
(select count(1) from IPautomata.link_action link_ack where link_ack.automaton_id = auto.automaton_id) as 'LinkedTo_Count',
#(select concat(login.FirstName,login.LastName) from auth.LOGIN login where login.LoginID = auto.editor_id) as 'Editor',
auto.execution_mode as 'ExecutionMode',
DATE(auto.created) as 'Created',
DATE(auto.modified) as 'Modified',
#auto.purpose as 'Purpose',
#auto.execution_mode as 'execution_mode',
#auto.created,
#auto.is_live,
#auto.is_archived,
auto.approval_status as 'ApprovalStatus'
#auto.approval_notes as 'ApprovalNotes'
from 
IPautomata.automaton auto
where
auto.modified >= "2017-03-31 23:59:59"
and auto.modified <= "2017-07-01 00:00:00"
and auto.is_live = 1
and auto.is_archived = 0
and auto.approval_status = "APPROVED"
and auto.client_id != 17
#and auto.approval_notes not like '%rfcID=135022%'
order by auto.modified desc
)automaton
order by ExecutionCount desc,LinkedTo_Count desc