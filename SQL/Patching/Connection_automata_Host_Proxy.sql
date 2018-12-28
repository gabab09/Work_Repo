select 
cl.ClientClientname as 'Client',
conn.connection_id  as 'ConnectionId',
conn.connection_name as 'ConnectionName',
conn.host as 'LiteralHost',
proxy_hop.host as 'ProxyHost'
from 
IPautomata.connection conn
inner join auth.CLIENT cl on conn.client_id = cl.ClientID
left join IPautomata.proxy_hop proxy_hop on conn.connection_id = proxy_hop.connection_id 
where
proxy_hop.host like  ('util0%.%') OR conn.host like  ('util0%.%') 
order by cl.ClientClientname,conn.connection_id,conn.connection_name
 

