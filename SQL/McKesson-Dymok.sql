select 

tkt.RdrTkt,
tkt.Desc,
tkt.ClientName,
tkt.CreatedDate

from
(select 
opntkt.ticket_id as 'RdrTkt',
opntkt.description as 'Desc',
(select y.ClientClientname from auth.CLIENT y where y.ClientID = opntkt.client_id) as 'ClientName',
opntkt.create_date as 'CreatedDate'
from
IPradar.tickets opntkt
where 
opntkt.description like ("%**%CI UPDATE%**%")
and opntkt.create_date >= "2016-11-01 00:00:00"

union 

select 
clstkt.ticket_id as 'RdrTkt',
clstkt.description as 'Desc',
(select y.ClientClientname from auth.CLIENT y where y.ClientID = clstkt.client_id) as 'ClientName',
clstkt.create_date as 'CreatedDate'
from
IPradar.tickets_resolved clstkt
where 
clstkt.description like ("%**%CI UPDATE%**%")
and clstkt.create_date >= "2016-11-01 00:00:00") tkt
where 
tkt.ClientName = 'Celesio'
order by tkt.CreatedDate desc