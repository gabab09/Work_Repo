select 
tr.ticket_id,
tr.description,
tr.create_date
from
IPradar.tickets_resolved tr
LEFT JOIN 
	IPradar.ipmon_ticket_mapping ipmon
	ON ipmon.ticket_id = tr.ticket_id
where 
ipmon.ticket_id is NULL
and tr.note like ('%-- IPimTicket --%')
and tr.note like ('%TicketID\:%')
and tr.note like ('%Tracking ID:[%][%]%')
and tr.note like ('%[Ticket Details]%')
and tr.note like ('%Transaction: Ticket created by%')
and tr.note like ('%Ticket URL:%')
and tr.note like ('%Subscribe%')
and tr.create_date >= "2017-04-01 00:00:00"
#and tr.ticket_id = 1920985

