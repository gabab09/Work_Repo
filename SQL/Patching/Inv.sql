select
exec.execution_id,
auto.name,
exec.created
from
IPautomata.execution exec, IPautomata.execution_variable execvar, IPautomata.automaton auto
where
exec.automaton_id = auto.automaton_id
and exec.execution_id = execvar.execution_id
and auto.name = "Prepatch_DownloadPatches_By_CI"
and execvar.name = "ci_hostname"

#and auto.name = "Sameday_Patch_Send_Notification_To_Users"
#and auto.name = "Prepatch_Send_Notification_To_Users"
#and execvar.name = "ci_full_list"

and execvar.value like ('%goltp5013.mckesson.com.mckesson%')
and exec.created >= "2017-09-01 00:00:00"

