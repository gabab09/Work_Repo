select 

openrfc.RFCID,
openrfc.RdrTicketID,
openrfc.IPimTicket,
openrfc.ClientCode,
openrfc.Description,
openrfc.Initiator,
openrfc.RadarOwner,
openrfc.LastUpdatedUser,
openrfc.CSIApprovalBy,
openrfc.WorkflowName,
openrfc.State,
openrfc.CurrentState,
openrfc.UpdatedAgo,
openrfc.CreatedDate,
openrfc.UpdatedDate
#(
#	select unhex(hex(att.Content))
#	from IPim.Transactions trx
#	left join IPim.Attachments att
#	on trx.id = att.TransactionId
#	where trx.ObjectId = openrfc.IPimTicket
#	and trx.Type = 'Correspond'
#	and trx.ObjectType = 'RT::Ticket'
#	order by trx.id desc
#	limit 1
#) as 'LastTranscation'

from

(select
a.rfc_id as 'RFCID',
b.ticket_id as 'RdrTicketID',
ipim.ipim_id as 'IPimTicket',
(select str_data.value from IPcm.rfc rfc, IPcm.rfc_attribute rfc_attr, IPcm.attribute_definition attr_def,IPcm.string_datum str_data where rfc.rfc_id = rfc_attr.rfc_id and rfc_attr.attribute_definition_id = attr_def.attribute_definition_id and rfc_attr.datum_id = str_data.datum_id and attr_def.description = "Client Code" and rfc.rfc_id = a.rfc_id) as 'ClientCode',
SUBSTRING_INDEX(c.description, 'Request for Change:', -1)  as 'Description',
(select CONCAT (x.FirstName," ",x.LastName) from auth.LOGIN x where x.LoginID = a.initiator_id) as 'Initiator',
(select CONCAT (x.FirstName," ",x.LastName) from auth.LOGIN x where x.LoginID = c.owner_id) as 'RadarOwner',
(select x.RealName from IPim.Users x, IPim.Tickets y,IPradar.ipim_ticket_mapping z where x.id = y.LastUpdatedBy and y.id = z.ipim_id and z.ticket_id = b.ticket_id  ) as 'LastUpdatedUser',
(select CONCAT (login.FirstName," ",login.LastName) from IPcm.rfc_log rfclog,IPcm.rfc rfc,auth.LOGIN login where rfclog.rfc_id=rfc.rfc_id and rfclog.action = 'APPROVE' and login.LoginID=rfclog.user_id and rfc.current_version_id = a.rfc_id LIMIT 1) as 'CSIApprovalBy',
b.workflow_name as 'WorkflowName',
a.status as 'State',
a.current_state as 'CurrentState',
TIMESTAMPDIFF(DAY, c.update_date , NOW()) as 'UpdatedAgo',
c.create_date as 'CreatedDate',
c.update_date as 'UpdatedDate'

from
IPcm.rfc a,IPradar.rfc_ticket_mapping b,IPradar.tickets c, IPradar.ipim_ticket_mapping ipim
where
a.rfc_id = b.rfc_id
and b.ticket_id = c.ticket_id
and ipim.ticket_id = b.ticket_id
and b.workflow_name like ('%CSI::%')
and a.status not in ('DRAFT','CLOSED','FAILED','PENDING')
and a.current_version_id is NULL	
order by TIMESTAMPDIFF(DAY, c.update_date , NOW() ) desc
) openrfc
#where 
#openrfc.ClientCode is not NULL
#and openrfc.CurrentState like '%CSI%'
#and openrfc.ClientCode in ('Ipsos','CCX') and openrfc.State in ('PENDING') #HealthCare
#and openrfc.ClientCode in ('Bombardier','CityOfDallas','Navisite','Amtrak','CRST') and openrfc.State in ('PENDING') #Gov/Transport
