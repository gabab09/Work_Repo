select 
eve.EventID,eve.StartTime,eve.Subject,eve_attr.Value as 'TargetGroup',
(select eve_sub.value from IPcal.EventAttribute eve_sub where eve_sub.Name="execution_id" and eve_sub.EventID=eve.EventID) as 'execution_id', 
eve.Deleted

from
IPcal.Event eve, IPcal.EventAttribute eve_attr
where 
eve.EventID = eve_attr.EventID
and eve.Subject like "%Run Same-Day-Patch Notification%"
and DATE(eve.StartTime) >= DATE(NOW())
and eve_attr.Name = "target_group"
order by eve.StartTime