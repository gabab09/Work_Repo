select  
(substring_index(substring_index(c.value,'JIRA-Subject==',-1),'==',1)) as 'RequestHeader',
count(1)

from  ebonding.ticket a, ebonding.ticket_log b,ebonding.ticket_attribute c ,IPradar.tickets_resolved d
where  
a.ticketID = b.ticketID and b.ticketLogID = c.ticketLogID  
and b.description  = "Incoming open request" 
and c.name = "Open Description" 
and a.radarTicketID = d.ticket_id
and c.value like '%IRA-Subject==%'
and d.create_date >= "2016-05-01 00:00:00"
group by RequestHeader
