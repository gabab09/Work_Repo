select 
eve.EventID,eve.StartTime,eve.Subject,eve_attr.Value as 'TargetGroup',
(select eve_sub.value from IPcal.EventAttribute eve_sub where eve_sub.Name="maint_date" and eve_sub.EventID=eve.EventID) as 'maint_date', 
(select eve_sub.value from IPcal.EventAttribute eve_sub where eve_sub.Name="frequency" and eve_sub.EventID=eve.EventID) as 'frequency',
(select eve_sub.value from IPcal.EventAttribute eve_sub where eve_sub.Name="wsus" and eve_sub.EventID=eve.EventID) as 'wsus',
eve.Deleted

from
IPcal.Event eve, IPcal.EventAttribute eve_attr
where 
eve.EventID = eve_attr.EventID
and eve.Subject like "%Run Pre-Patch Notification - Version%"
and DATE(eve.StartTime) >= DATE(NOW())
and eve_attr.Name = "target_group"