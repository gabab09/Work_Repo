select 
AOSS.Client,
AOSS.ProblemTkt,
AOSS.Type,
AOSS.Subject,
AOSS.IPpmOwner,
AOSS.ActionTkt,
AOSS.Status,
AOSS.createdate,
AOSS.Radar,
AOSS.IPimTkt,
AOSS.ResolvedBy,
#AOSS.resolution,
#AOSS.known_problem,
#AOSS.workaround,
#AOSS.root_cause,
(
	select unhex(hex(att.Content))
	from IPim.Transactions trx
	left join IPim.Attachments att
	on trx.id = att.TransactionId
	where trx.ObjectId = AOSS.IPimTkt
	and trx.Type = 'Correspond'
	and trx.ObjectType = 'RT::Ticket'
	order by trx.id desc
	limit 1
) as 'LastTranscation'

from 
(
select
pro.problem_id as 'ProblemTkt',
SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, '] ', 2), '[',-1) as 'Client',
SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), '-',1) as 'Type',
case 
when (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), '-',1) ) like '%Alert missing automation%'
then (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), 'Alert missing automation - ',-1) ) 
when (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), '-',1)) like '%Execution Failure%'
then (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), 'Execution Failure - ',-1) ) 
when (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), '-',1)) like '%Diagnosis to Remediation Opportunity%'
then (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), 'Diagnosis to Remediation Opportunity - ',-1) ) 
when (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), '-',1)) like '%Automation Collision%'
then (SUBSTRING_INDEX(SUBSTRING_INDEX(pro.subject, ':  ', -1), 'Automation Collision - ',-1) ) 
else
'-'
end as 'Subject',
(select concat(login.FirstName,' ',login.LastName) from IPradar.tickets rdr_tkt, auth.LOGIN login where rdr_tkt.owner_id = login.LoginID and rdr_tkt.ticket_id = pro.ticket_id) as 'IPpmOwner',
(select group_concat(action.ticket_id) from IPpm.problem_action_association action where action.problem_id = pro.problem_id ) as 'ActionTkt',
pro.status as 'Status',
pro.created as 'createdate',
pro.ticket_id as 'Radar',
(select ipim_map.ipim_id from IPradar.ipim_ticket_mapping ipim_map where ipim_map.ticket_id = pro.ticket_id) as 'IPimTkt',
(select GROUP_CONCAT(login.FirstName,' ',login.LastName) from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = pro.ticket_id  LIMIT 1) as 'ResolvedBy'
#pro.resolution,
#pro.known_problem,
#pro.workaround,
#pro.root_cause,

from 
IPpm.problem pro
where
pro.subject like "%[AOSS] [%"
and pro.status = "Active"
#and pro.created >= "2017-03-01 00:00:00"
) AOSS
order by AOSS.Type,AOSS.createdate