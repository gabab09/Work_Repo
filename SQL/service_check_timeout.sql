select
tr.ticket_id,
tr.description,
ipmon.service,
tr.create_date
from IPradar.tickets_resolved tr
inner join IPradar.ipmon_ticket_mapping ipmon
on tr.ticket_id = ipmon.ticket_id
where tr.create_date >= '2017-07-01 00:00:00'
and tr.note REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?'
