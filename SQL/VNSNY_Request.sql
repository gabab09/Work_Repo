select report.RequestHeader,report.RequestFor,report.AlertCount
from

(select  
(substring_index(substring_index(c.value,'JIRA-Subject==',-1),'==',1)) as 'RequestHeader',

CASE when (c.value) like '%IRA-Subject==Software Request==%' 
then (substring_index(substring_index(c.value,'JIRA-Software==',-1),'==',1))  

when (c.value) like '%IRA-Subject==Hardware Request==%' 
then(substring_index(substring_index(c.value,'JIRA-Hardware Type==',-1),'==',1)) 

when (c.value) like '%IRA-Subject==Share Network Drive Access%' 
then
	case when (c.value) like '%JIRA-Shared Drive Directory Path==%'
	then (substring_index(substring_index(c.value,'JIRA-Shared Drive Directory Path==[',-1),']==',1)) 
	when (c.value) like '%JIRA-What is the name of the folder you need created?==%'
	then (substring_index(substring_index(c.value,'JIRA-What is the name of the folder you need created?==',-1),'==',1)) 
	else 'Other'
	end

when (c.value) like '%IRA-Subject==Web Application Access==%' 
then
	case when (c.value) like '%JIRA-Web Application==%'
	then (substring_index(substring_index(c.value,'JIRA-Web Application==[',-1),']==',1))
	when (c.value) like '%JIRA-Additional Explanation==%'
	then (substring_index(substring_index(c.value,'JIRA-Additional Explanation==',-1),'==',1))
	when (c.value) like '%JIRA-Level of EOS Access==%'
	then (substring_index(substring_index(c.value,'JIRA-Level of EOS Access==',-1),'==',1))
	when (c.value) like '%JIRA-Please specify which area in ImageNow you are requesting access to.==%'
	then (substring_index(substring_index(c.value,'JIRA-Please specify which area in ImageNow you are requesting access to.==',-1),'==',1))
	else 'Other'
	end

when (c.value) like '%IRA-Subject==Password Reset==%' 
then
	case when (c.value) like '%JIRA-Application==%'
	then (substring_index(substring_index(c.value,'JIRA-Application==',-1),'==',1))
	else 'Other'
	end

when (c.value) like '%IRA-Subject==Security Group Request==%' 
then
	case when (c.value) like '%JIRA-Security Groups==%'
	then (substring_index(substring_index(c.value,'JIRA-Security Groups==[',-1),']==',1))
	when (c.value) like '%JIRA-New Security Group Name==%'
	then (substring_index(substring_index(c.value,'JIRA-New Security Group Name==',-1),'==',1))
	else 'Other'
	end

when (c.value) like '%IRA-Subject==Efax Inbound Folder Access==%' 
then
	case when (c.value) like '%JIRA-What is the path of the Efax Inbound Folder?==%'
	then (substring_index(substring_index(c.value,'JIRA-What is the path of the Efax Inbound Folder?==',-1),'==',1))
	else 'Other'
	end

else 'Other'

end as 'RequestFor',
count(1) as 'AlertCount'

from  ebonding.ticket a, ebonding.ticket_log b,ebonding.ticket_attribute c ,IPradar.tickets_resolved d
where  
a.ticketID = b.ticketID and b.ticketLogID = c.ticketLogID  
and b.description  = "Incoming open request" 
and c.name = "Open Description" 
and a.radarTicketID = d.ticket_id
and c.value like '%IRA-Subject==%'
and d.create_date >= "2016-05-01 00:00:00"
group by RequestFor,RequestHeader) report

order by report.AlertCount desc
