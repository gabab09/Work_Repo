select
exec_var.value as ci_hostname,
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_over_all_status" LIMIT 1) as 'ci_patch_over_all_status',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_maintenance_date" LIMIT 1) as 'cmdb_maintenance_date',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_rfc" LIMIT 1) as 'ci_patch_rfc',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patchs_installed_count" LIMIT 1) as 'ci_patchs_installed_count',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patchs_installed_name" LIMIT 1) as 'ci_patchs_installed_name',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_last_patched" LIMIT 1) as 'ci_last_patched',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_last_reboot" LIMIT 1) as 'ci_last_reboot',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_radar" LIMIT 1) as 'ci_patch_radar',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_execution" LIMIT 1) as 'ci_patch_execution',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_execution_sttime" LIMIT 1) as 'ci_patch_execution_sttime',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_patch_execution_status" LIMIT 1) as 'ci_patch_execution_status',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_os_type" LIMIT 1) as 'ci_os_type',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "ci_space" LIMIT 1) as 'ci_space',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_ipsoft_managed" LIMIT 1) as 'cmdb_ipsoft_managed',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_ipsoft_monitored" LIMIT 1) as 'cmdb_ipsoft_monitored',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_next_maintenance_date" LIMIT 1) as 'cmdb_next_maintenance_date',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_patch_frequency" LIMIT 1) as 'cmdb_patch_frequency',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_reboot_pointer" LIMIT 1) as 'cmdb_reboot_pointer',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_server_status" LIMIT 1) as 'cmdb_server_status',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_service_level" LIMIT 1) as 'cmdb_service_level',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "cmdb_target_group" LIMIT 1) as 'cmdb_target_group',
(select exec_var_sub.value from IPautomata.execution_variable exec_var_sub where exec_var_sub.execution_id = exec.execution_id and exec_var_sub.name = "pat_tuesday_date" LIMIT 1) as 'pat_tuesday_date'



from
IPautomata.automaton auto, IPautomata.execution exec, IPautomata.execution_variable exec_var
where
auto.automaton_id = exec.automaton_id
and exec.execution_id = exec_var.execution_id
and exec_var.name = "ci_hostname"
#and exec_var.value = "mtsw-012.oc.mckesson"
and exec.creator_id is NULL
#and exec.ticket_id = 486
and auto.original_id = 29724
and exec.created >= "2017-07-01 21:00:00"
order by exec.created desc 
