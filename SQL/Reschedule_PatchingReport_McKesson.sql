select
rdrtkt.ticket_id,
#rdrtkt.description,
TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rdrtkt.note, 'CI Name', -1),'Reschedule Date',1),': ',-1), '\n', ' '), '\r', ' '), '\t', ' ')) as 'Server',
TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rdrtkt.note, 'Reschedule Date (MM/DD/YYYY)', -1),'Reschedule Hours in PST (0 to 23)',1),': ',-1), '\n', ' '), '\r', ' '), '\t', ' ')) as 'RescheduleDate',
TRIM(REPLACE(REPLACE(REPLACE(SUBSTRING_INDEX(SUBSTRING_INDEX(SUBSTRING_INDEX(rdrtkt.note, 'Reschedule Hours in PST (0 to 23)', -1),'Reason for Reschedule',1),': ',-1), '\n', ' '), '\r', ' '), '\t', ' ')) as 'RescheduleTime'
from
IPradar.tickets_resolved rdrtkt
where
rdrtkt.description like ('%McKesson : Windows Reschedule Patching%')
and rdrtkt.create_date >= "2017-09-01 00:00:00"


