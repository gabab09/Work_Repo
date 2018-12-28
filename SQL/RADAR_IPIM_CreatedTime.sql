select a.ticket_id,a.create_date,b.creation_date,c.Created,d.Name

from 
IPradar.tickets_resolved a, IPradar.ipim_ticket_mapping b, IPim.Tickets c, IPim.Queues d, IPim.Transactions e
where 
a.ticket_id = b.ticket_id
and b.ipim_id = c.id
and c.Queue = d.id
and b.ipim_id = e.id
and a.ticket_id = 1097930