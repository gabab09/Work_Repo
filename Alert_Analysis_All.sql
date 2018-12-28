SET @start_date = '2018-09-01 00:00:00';
SET @end_date = '2018-11-21 11:00:00'; 
SET @automataid = 'ipautolvsprod';

select
ticket_rawdata.Client,
ticket_rawdata.TicketOrigin,
ticket_rawdata.RadarTkt,
ticket_rawdata.IPimTicket,
ticket_rawdata.MasterTicket,
ticket_rawdata.Owner,
ticket_rawdata.IPimCreator,
ticket_rawdata.LastUpdatedBy,
ticket_rawdata.ResolvedBy,
ticket_rawdata.IPimQueue,
ticket_rawdata.Status,
REPLACE(REPLACE(ticket_rawdata.Description, '\r', ''), '\n', '') as 'Description',
ticket_rawdata.HostName,
ticket_rawdata.OSType,
ticket_rawdata.State,
case 
    when ((ticket_rawdata.Service = 'IPremoted') AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'IPremoted'    
    when ((ticket_rawdata.AdditionalInformation REGEXP 'State: UNKNOWN|(Hard|Service Check|Connection) (Time[d ]*out|refused)|System.OutOfMemoryException was thrown|\d+ is out of bounds|Invalid protocol|(Could |Can)not connect to( vmware: Error connecting to server)?') AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'ServiceCheckTimeout'
    when ((ticket_rawdata.AlertType = 'Host') AND ((ticket_rawdata.Service is NULL) OR (ticket_rawdata.Service = '')) AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'HostDown' 
    when ((ticket_rawdata.Service like 'Interface%Errors') AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Interface Errors'
    when ((ticket_rawdata.Service like 'Interface%Utilization')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Interface Utilization'
    when ((ticket_rawdata.Service like 'Interface%Status')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Interface Status'

    when ((ticket_rawdata.Service like 'Cisco IPSec Tunnels%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco IPSec Tunnels'
    when ((ticket_rawdata.Service like 'Cisco QoSGigabitEthernet%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco QoSGigabitEthernet'
    when ((ticket_rawdata.Service like 'Cisco CUCM processes%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco CUCM processes'
    when ((ticket_rawdata.Service like 'Cisco CUCM Gateways%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco CUCM Gateways'
    when ((ticket_rawdata.Service like 'Block Device Performance%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Block Device Performance'
    when ((ticket_rawdata.Service like 'Blackberry Services%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Blackberry Services'
    when ((ticket_rawdata.Service like 'Chassis Status%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Chassis Status'
    when ((ticket_rawdata.Service like 'BGP%PeerRestart%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'BGP PeerRestart'
    when ((ticket_rawdata.Service like 'Asigra Cloud Backup%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Asigra Cloud Backup'
    when ((ticket_rawdata.Service like 'Active Directory%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Active Directory'
    when ((ticket_rawdata.Service like 'Access Point Radio%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Access Point'
    when ((ticket_rawdata.Service like 'Access Point Interface%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Access Point Interface'
    when (((ticket_rawdata.Service like '%Interfaces %') OR (ticket_rawdata.Service like 'Interfaces-%'))  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Interfaces'
    when ((ticket_rawdata.Service like 'Access Point%APAdminStatus%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Access Point APAdminStatus'
    when ((ticket_rawdata.Service like 'Aggregate Usage%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Aggregate Usage'
    when ((ticket_rawdata.Service like 'Application Pools%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Application Pools'
    when ((ticket_rawdata.Service like 'Cisco UCS Blades%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco UCS Blades'
    when ((ticket_rawdata.Service like 'Citrix Services%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Citrix Services'
    when ((ticket_rawdata.Service like 'Client Access%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Client Access'
    when ((ticket_rawdata.Service like 'Cluster Failover%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cluster Failover'
    when ((ticket_rawdata.Service like 'Cluster Node State%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cluster Node State'
    when ((ticket_rawdata.Service like 'Cluster Partition Utilitization%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cluster Partition Utilitization'
    when ((ticket_rawdata.Service like 'Cluster Resource State%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cluster Resource State'
    when ((ticket_rawdata.Service like 'CommVault Job Status%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'CommVault Job Status'
    when ((ticket_rawdata.Service like 'CPU Overview-Core Count%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'CPU Overview-Core Count'
    when ((ticket_rawdata.Service like 'CPU Per Core%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'CPU Per Core'
    when ((ticket_rawdata.Service like 'CPU.%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'CPU'
    when ((ticket_rawdata.Service like 'CPU-Chassis%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'CPU-Chassis'
    when ((ticket_rawdata.Service like 'Disk %:')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Disk'
    when ((ticket_rawdata.Service like 'Disk./%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Unix Disk'
    when ((ticket_rawdata.Service like 'EIGRP Peers%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'EIGRP Peers'
    when ((ticket_rawdata.Service like 'Exchange Database Store%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Exchange Database Store'
    when ((ticket_rawdata.Service like 'ESX Temperature Sensors%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'ESX Temperature Sensors'
    when ((ticket_rawdata.Service like 'Fan S%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Cisco Fan '
    when ((ticket_rawdata.Service like 'Fault Table-Active%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Fault Table-Active'
    when ((ticket_rawdata.Service like 'FortiNet FortiGate Interfaces%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'FortiNet FortiGate Interfaces'
    when ((ticket_rawdata.Service like 'FRU%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'FRU'
    when (((ticket_rawdata.Service like 'HTTPS%') OR (ticket_rawdata.Service like 'HTTP-%')) AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'URL Alert'
    when ((ticket_rawdata.Service like 'HyperV Virtual Machines%AveragePressure')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'HyperV Virtual Machines AveragePressure'
    when ((ticket_rawdata.Service like 'IIS Application Pool%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'IIS Application Pool'
    when ((ticket_rawdata.Service like 'Interface Health%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Interface Health'
    when ((ticket_rawdata.Service like 'Logical Drive Performance%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Logical Drive Performance'
    when ((ticket_rawdata.Service like 'Line Card Status%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Line Card Status'
    when ((ticket_rawdata.Service like 'Machines-%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Machines State Alert'
    when ((ticket_rawdata.Service like 'Memory %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Memory'
    when ((ticket_rawdata.Service like 'Physical Disks%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Physical Disks'
    when ((ticket_rawdata.Service like 'Netscaler Configs%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Netscaler Configs'
    when ((ticket_rawdata.Service like 'Power Supplies%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Power Supplies'
    when ((ticket_rawdata.Service like 'Serial Ports%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Serial Ports'
    when (((ticket_rawdata.Service like 'Services_Auto%') OR ( ticket_rawdata.Service like 'Services-Microsoft Exchange%') OR ( ticket_rawdata.Service like  'Windows Service.%'))  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Services'
    when ((ticket_rawdata.Service like 'SQL Server-MSSQL%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'SQL Server-MSSQL'
    when ((ticket_rawdata.Service like 'SQL Services-%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'SQL Services'
    when ((ticket_rawdata.Service like 'SQL Server-%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'SQL Server Alerts'
    when (((ticket_rawdata.Service like 'System Uptime%') OR (ticket_rawdata.Service like 'Uptime.%') OR (ticket_rawdata.Service like 'Uptime-%'))  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'System Uptime'
    when ((ticket_rawdata.Service like 'SQL%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'SQL'
    when ((ticket_rawdata.Service like 'TCP %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'TCP'
    when ((ticket_rawdata.Service like 'Traffic.%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Traffic'
    when ((ticket_rawdata.Service like 'UCS Fault Table%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'UCS Fault Table'
    when ((ticket_rawdata.Service like 'vCenter Admission Control%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'vCenter Admission Control-'
    when ((ticket_rawdata.Service like 'VMware Host Datastore Capacity%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Host Datastore Capacity'
    when ((ticket_rawdata.Service like 'VMware Host Datastore Performance%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Host Datastore Performance'
    when ((ticket_rawdata.Service like 'VMware Host Network Interfaces%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Host Network Interfaces'
    when ((ticket_rawdata.Service like 'VMware Host Hardware Sensors%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Host Hardware Sensors'
    when ((ticket_rawdata.Service like 'VMware Host Performance%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Host Performance'
    when ((ticket_rawdata.Service like 'VMware Network Status%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware Network Status'
    when ((ticket_rawdata.Service like 'VMware VM Disk Capacity%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware VM Disk Capacity'
    when ((ticket_rawdata.Service like 'VMware VM Snapshots%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'VMware VM Snapshots'
    when ((ticket_rawdata.Service like 'Volume Capacity%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Volume Capacity'
    when ((ticket_rawdata.Service like 'Volume Performance%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Volume Performance'
    when ((ticket_rawdata.Service like 'Windows%Event Log%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Event Log'
    when ((ticket_rawdata.Service like 'Wifi  Interfaces%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Wifi  Interfaces'
    when ((ticket_rawdata.Service like 'Windows Asigra Backup Events%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Backup'
    when ((ticket_rawdata.Service like 'Windows Stuck Print Jobs%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Stuck Print Jobs'
    when ((ticket_rawdata.Service like 'Zerto VPG%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Zerto VPG'
    
    when ((ticket_rawdata.Service like 'Disk - /%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Unix Disk'
    when ((ticket_rawdata.Service like 'Disk%-%C:')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows System Disk'
    when ((ticket_rawdata.Service like 'Disk%-%:')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Windows Data Disk'
    when ((ticket_rawdata.Service like 'Inodes - /%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Unix Inode'
    when ((ticket_rawdata.Service like 'Service - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Service'      
    when ((ticket_rawdata.Service like '%Proc - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Unix Proc'    
    when ((ticket_rawdata.Service like '%Uptime - %docker%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Docker Uptime'    
    when ((ticket_rawdata.Service like '%Network Utilization - %docker%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Docker Network Utilization'   
    when ((ticket_rawdata.Service like '%Memory Usage - %docker%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Docker Memory Usage'  
    when ((ticket_rawdata.Service like '%CPU Usage%docker%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Docker CPU Usage' 
    when ((ticket_rawdata.Service like '%BlockIO - %docker%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Docker BlockIO'   
    when ((ticket_rawdata.Service like '%Uptime - %swarm%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Dockerswarm Uptime'   
    when ((ticket_rawdata.Service like '%Network Utilization - %swarm%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Dockerswarm Network Utilization'  
    when ((ticket_rawdata.Service like '%Memory Usage - %swarm%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Dockerswarm Memory Usage' 
    when ((ticket_rawdata.Service like '%CPU Usage%swarm%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Dockerswarm CPU Usage'    
    when ((ticket_rawdata.Service like '%BlockIO - %swarm%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Dockerswarm BlockIO'  
    when ((ticket_rawdata.Service like '%Uptime - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Other Uptime' 
    when ((ticket_rawdata.Service like '%Network Utilization - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Other Network Utilization'    
    when ((ticket_rawdata.Service like '%Memory Usage - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Other Memory Usage'   
    when ((ticket_rawdata.Service like '%CPU Usage%%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Other CPU Usage'  
    when ((ticket_rawdata.Service like '%BlockIO - %%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Other BlockIO'
    when ((ticket_rawdata.Service like '%JBOSS %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'JBOSS'    
    when ((ticket_rawdata.Service like '%Webcheck_%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Webcheck' 
    when ((ticket_rawdata.Service like '%Web Port -%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Web Port'         
    when ((ticket_rawdata.Service like '%WebLogic %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'WebLogic' 
    when ((ticket_rawdata.Service like '%DVL %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'DVL'  
    when ((ticket_rawdata.Service like '%File Age %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'File Age'
    when ((ticket_rawdata.Service like '%WebSphere %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'WebSphere'    
    when ((ticket_rawdata.Service like '%TOMCAT %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'TOMCAT'           
    when ((ticket_rawdata.Service like '%Oracle %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Oracle'           
    when ((ticket_rawdata.Service like '%Alert%Scrubber%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Alert Scrubber'           
    when ((ticket_rawdata.Service like '%MSSQL %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'MSSQL'
    when ((ticket_rawdata.Service like '%File%Exists%')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'File Exists'
    when ((ticket_rawdata.Service like 'DB2 %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'File Exists'
    when (((ticket_rawdata.Service like '%Sybase %') OR (ticket_rawdata.Service like '%SybStat%'))  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Sybase'
    when ((ticket_rawdata.Service like '%Apache HTTP %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Apache HTTP'
    when ((ticket_rawdata.Service like '%Process - %')  AND (ticket_rawdata.TicketOrigin = 'IPmon'))
        then 'Process - '
    when ((ticket_rawdata.Description like '**%CI%UPDATE%**%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Dymok'            
    when ((ticket_rawdata.Description like '%vRealize%Operations%Manager%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'VROPS'            
    when ((ticket_rawdata.Description like '%Decommission%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Decommission'         
    when ((ticket_rawdata.Description like '%Hardware%Monitoring%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Hardware Monitoring'          
    when ((ticket_rawdata.Description like '%Control%M%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Control-M'            
    when ((ticket_rawdata.Description like '%Validate%DFS%Share%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'DFS Share'            
    when (((ticket_rawdata.Description like '%VDI%') || (ticket_rawdata.Description like '%Virtual%Desktop%Instance%')) AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'VDI'          
    when ((ticket_rawdata.Description like '%Install%Enable%AVAMAR%backup%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Install AVAMAR'           
    when ((ticket_rawdata.Description like '%IdentityIQ%Access%Request%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'IdentityIQ Access Request'            
    when ((ticket_rawdata.Description like '%message%from%VNXe%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Message from VNXe'            
    when ((ticket_rawdata.Description like '%SPLUNK %') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'SPLUNK'           
    when ((ticket_rawdata.Description like '%XtremIO%System%Event%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'XtremIO'          
    when ((ticket_rawdata.Description like '%Add%Share%Drive%Access%%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Share Drive Access'           
    when ((ticket_rawdata.Description like '%Shutdown%Server%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Shutdown Server'          
    when ((ticket_rawdata.Description like '%Delete%VM%Disk') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Delete VM from Disk'          
    when ((ticket_rawdata.Description like '%System%Notification%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'System Notification'          
    when ((ticket_rawdata.Description like '%Unable%to%login%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Unable to login'          
    when ((ticket_rawdata.Description like '%Build%OS%Configure%AD%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Build OS and Configure AD groups'         
    when ((ticket_rawdata.Description like '%Modify%Storage%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Modify-Storage'           
    when ((ticket_rawdata.Description like '%Server%QA%Delivery%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Server QA & Delivery'         
    when ((ticket_rawdata.Description like '%Recover%IP%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Recover IP'           
    when ((ticket_rawdata.Description like '%Server%Request%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Server Request'           
    when ((ticket_rawdata.Description like '%TRF%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'TRF'
    when ((ticket_rawdata.Description like '%Access%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Access'
    when ((ticket_rawdata.Description like '%REPORT - %') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'REPORT'
    when ((ticket_rawdata.Description like '%IBM%Incentive%Compensation%Management%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'ICS'      
    when ((ticket_rawdata.Description like '%Phoenix%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Phoenix'      
    when ((ticket_rawdata.Description like '%Pyramid%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Pyramid'          
    when ((ticket_rawdata.Description like '%Storage%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Storage'          
    when ((ticket_rawdata.Description like '%EMC%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'EMC'  
    when ((ticket_rawdata.Description like '%SFDC%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'SFDC' 
    when ((ticket_rawdata.Description like '%EBS%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'EBS'          
    when ((ticket_rawdata.Description like '%SharePoint%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'SharePoint'       
    when ((ticket_rawdata.IPimCreator like '%cisco-ros%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Alert from cisco-ros.com' 
    when ((ticket_rawdata.IPimCreator like '%L0Monitoring%') AND (ticket_rawdata.TicketOrigin = 'NonIPmonTicket'))
        then 'Alert from ME'            
    when (((ticket_rawdata.Service like '%Ended not OK%') OR (ticket_rawdata.Service like '%failed.') OR (ticket_rawdata.Service like '%failed during%') OR (ticket_rawdata.Service like '%JOB% FAILED %')) AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'FAILURE'  
    when ((ticket_rawdata.Service like '%STATUS OF AGENT PLATFORM%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Change in Status of Platform' 
    when (((ticket_rawdata.Service like '%running long%') OR (ticket_rawdata.Service like '%running late%') OR (ticket_rawdata.Service like '%executing over%')) AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Long Running' 
    when ((ticket_rawdata.Service like '%min_delta%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Delta'    
    when ((ticket_rawdata.Service like '%running late%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Running Late' 
    when ((ticket_rawdata.Service like '% Warning %') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Warning'  
    when ((ticket_rawdata.Service like '% SHOUT TO %') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Shout'    
    when ((ticket_rawdata.Service like '%job not running%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Job not running'  
    when ((ticket_rawdata.Service like '%Service REPORTS%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Service REPORTS'  
    when ((ticket_rawdata.Service like '%No action required%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'No action required'   
    when ((ticket_rawdata.Service like '%EMAIL TO%FAILED%') AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'EMAIL TO FAILED'  
    when (((ticket_rawdata.Service like '%Send %mail to%') OR (ticket_rawdata.Service like '%Contact Admin%') OR (ticket_rawdata.Service like '% CALL %')  OR (ticket_rawdata.Service like '% Inform %')) AND (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM'))
        then 'Notify'   
    when (ticket_rawdata.TicketOrigin = 'IPcollector-ControlM')
        then 'Other'    
        else
    ticket_rawdata.Service
end
as 'UpdatedService',

ticket_rawdata.Service,
ticket_rawdata.AlertType,
ticket_rawdata.Environment,
ticket_rawdata.Tier,
ticket_rawdata.Site,
ticket_rawdata.Operational_Support,
ticket_rawdata.DeviceType,
ticket_rawdata.Monitored,
ticket_rawdata.IPsoftManaged,
ticket_rawdata.RD_AutomataName,
ticket_rawdata.EU_AutomataName,
ticket_rawdata.RD_AutomataPurpose,
ticket_rawdata.EU_AutomataPurpose,
ticket_rawdata.RD_AutomataStatus,
ticket_rawdata.EU_AutomataStatus,
ticket_rawdata.AutomataResolved,
ticket_rawdata.AutomataFailed,
ticket_rawdata.AutomataAssisted,
ticket_rawdata.AutomataEscalated,
ticket_rawdata.AutomataAction,
ticket_rawdata.NumberOfAutoamta,
ticket_rawdata.Time_To_Respond,
ticket_rawdata.Time_To_Resolution,
ticket_rawdata.Priority,
ticket_rawdata.CreateDateTime,
ticket_rawdata.ResolveDateTime,
TIMESTAMPDIFF(MINUTE,ticket_rawdata.CreateDateTime,ticket_rawdata.ResolveDateTime) as 'TicketDuration',
ticket_rawdata.CreateDate,
ticket_rawdata.CreateTimeHour,
ticket_rawdata.CreateMonth,
ticket_rawdata.ExternalTicket

from

(
    select 
    ipcenter_ticket.ClientClientname as 'Client',
    ipcenter_ticket.ticket_id as 'RadarTkt',
    (select ipim_tkt_map.ipim_id from IPradar.ipim_ticket_mapping ipim_tkt_map where ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'IPimTicket',
    ipcenter_ticket.master_ticket_id as 'MasterTicket',
    
    (select login.Username from auth.LOGIN login where login.LoginID = ipcenter_ticket.owner_id) as 'Owner',
    (select ipim_u.Name from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im, IPim.Users ipim_u  where ipim_im.Creator = ipim_u.id  and ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'IPimCreator',
    (select ipim_u.Name from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im, IPim.Users ipim_u  where ipim_im.LastUpdatedBy = ipim_u.id  and ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'LastUpdatedBy',
    (select ipim_im.LastUpdated from IPradar.ipim_ticket_mapping ipim_tkt_map,IPim.Tickets ipim_im where ipim_tkt_map.ipim_id = ipim_im.id and ipim_tkt_map.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'LastUpdated',    

    (select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = ipcenter_ticket.ticket_id  LIMIT 1) as 'ResolvedBy',
    
    (select ipim_q.Name from IPim.Queues ipim_q,IPim.Tickets ipim_tkt,IPradar.ipim_ticket_mapping ipim_radar where ipim_radar.ipim_id = ipim_tkt.id and ipim_tkt.Queue = ipim_q.id and ipim_radar.ticket_id=ipcenter_ticket.ticket_id) as 'IPimQueue',
    (select status_ipradar.status_type from IPradar.status status_ipradar where status_ipradar.status_id = ipcenter_ticket.status_id) as 'Status',
    ipcenter_ticket.description as 'Description',
    
    CASE
        when (ipcenter_ticket.note) like ('%Attribute: ipsoft_source=%')
            then (select CONCAT('IPcollector-',ipradar_tkt_attr.value) from IPradar.ticket_attribute ipradar_tkt_attr where ipradar_tkt_attr.ticket_id = ipcenter_ticket.ticket_id and ipradar_tkt_attr.name = 'ipsoft_source')
        when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
            then ('IPmon')
        when (select rfc_tkt_map.rfc_id from IPradar.rfc_ticket_mapping rfc_tkt_map where rfc_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
            then ('RFC')
        else ('NonIPmonTicket')
    end as 'TicketOrigin',
    
    (select ipim_radar.host_name from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'HostName',
    (select ipim_radar.service from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'Service',
    (select ipim_radar.alert_type from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'AlertType',
    (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Prod-NonProd" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Environment',
    (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Tier" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Tier',
    (select ipcmdb_ci_ass.name from IPcmdb.ci_association ci_ass, IPcmdb.ci ipcmdb_ci_ass,IPradar.ipcmdb_ticket_mapping cmdb_ci where  ci_ass.target_ci_id = ipcmdb_ci_ass.ci_id and ci_ass.source_ci_id = cmdb_ci.ci_id and ci_ass.association_type_id = '3' and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) as 'Site',
    (select ipim_radar.state from IPradar.ipmon_ticket_mapping ipim_radar where ipim_radar.ticket_id=ipcenter_ticket.ticket_id ) as 'State',

    CASE
        when (select ipmon_tkt_map.ipmon_host from IPradar.ipmon_ticket_mapping ipmon_tkt_map where ipmon_tkt_map.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
            then ipcenter_ticket.note 
        else 'NA'
    end as 'AdditionalInformation',
    
    CASE 
    when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
    then 
        case
            when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
                then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
            when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
                then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "Database Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
            else 'NULL'
        end
    else 
        case
            when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
                then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
            when (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
                then (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_ci where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_ci.ci_id and cmdb_attrdef.name = "Database Type" and cmdb_ci.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
            else 'NULL'
        end
    end as 'DeviceType',
    
    case
        when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Monitored" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 1
            then ('True')
        else ('False')
    end as 'Monitored',
    

    case
        when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 0
            then ('False')
        when (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "IPsoft Managed" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) = 1
            then ('True')
        else ('NA')
    end as 'IPsoftManaged',
    
    (select cmdb_bd.value from IPcmdb.boolean_datum cmdb_bd,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_bd.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "Operational Support" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)  as 'Operational_Support',
    
    
    CASE 
        when (select rfc_rdr.rfc_id from IPradar.rfc_ticket_mapping rfc_rdr where rfc_rdr.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) is NOT NULL
            then 
            (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPcm.rfc_ci rfc_ci,IPradar.rfc_ticket_mapping rfctktmap where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = rfc_ci.ci_id and cmdb_attrdef.name = "OS Type" and rfc_ci.rfc_id = rfctktmap.rfc_id and rfctktmap.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
        else
            (select cmdb_st.value from IPcmdb.string_datum cmdb_st,IPcmdb.ci_attribute cmdb_attr,IPcmdb.attribute_definition cmdb_attrdef,IPradar.ipcmdb_ticket_mapping cmdb_rdr where cmdb_st.datum_id = cmdb_attr.datum_id and cmdb_attr.attribute_definition_id = cmdb_attrdef.attribute_definition_id and cmdb_attr.ci_id = cmdb_rdr.ci_id and cmdb_attrdef.name = "OS Type" and cmdb_rdr.ticket_id = ipcenter_ticket.ticket_id LIMIT 1)
    end as 'OSType',
    
    
    (select GROUP_CONCAT(auto.name SEPARATOR ', ') from IPautomata.execution exec_sub,IPautomata.automaton auto where exec_sub.automaton_id=auto.automaton_id and exec_sub.ticket_id= ipcenter_ticket.ticket_id  and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION','UTILITY') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'RD_AutomataName',
    (select GROUP_CONCAT(exec_sub.status SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION','UTILITY') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'RD_AutomataStatus',
    (select GROUP_CONCAT(exec_sub.purpose SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose not in ('ESCALATION','UTILITY') and  (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec_sub.ticket_id) as 'RD_AutomataPurpose',

    (select GROUP_CONCAT(auto.name SEPARATOR ', ') from IPautomata.execution exec_sub,IPautomata.automaton auto where exec_sub.automaton_id=auto.automaton_id and exec_sub.ticket_id= ipcenter_ticket.ticket_id  and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose in ('ESCALATION','UTILITY') group by exec_sub.ticket_id) as 'EU_AutomataName',
    (select GROUP_CONCAT(exec_sub.status SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose in ('ESCALATION','UTILITY') group by exec_sub.ticket_id) as 'EU_AutomataStatus',
    (select GROUP_CONCAT(exec_sub.purpose SEPARATOR ', ') from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and exec_sub.purpose in ('ESCALATION','UTILITY') group by exec_sub.ticket_id) as 'EU_AutomataPurpose',
    
    
   CASE 
   when (((select login.Username from IPradar.ticket_log tkt_log, auth.LOGIN login where tkt_log.editor_id = login.LoginID and tkt_log.action_type = 'RESOLVE' and tkt_log.ticket_id = ipcenter_ticket.ticket_id LIMIT 1) in ('ipautomata',@automataid)) AND ((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= ipcenter_ticket.ticket_id and exec.status not in ('AUTO_ABORTED') and (exec.creator_id is NULL OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec.creator_id = (select LoginID from auth.LOGIN where Username = @automataid)) group by exec.ticket_id ) is NOT NULL))
       then 'REMEDIATION'

   when (select tkt_log.action_description from IPradar.ticket_log tkt_log where  tkt_log.ticket_id = ipcenter_ticket.ticket_id and tkt_log.action_description = 'Autoresolve IPmon Alert') is NOT NULL  
       then 'NA-REMEDIATION'

   when (((select count(exec.ticket_id) from IPautomata.execution exec where exec.ticket_id= ipcenter_ticket.ticket_id and exec.status not in ('AUTO_ABORTED') and exec.creator_id is NULL  group by exec.ticket_id) is not NULL))
       then 'DIAGNOSIS'

   else 'NO-AUTOMATA'
   end as 'AutomataAction',
(select count(exec_sub.ticket_id) from IPautomata.execution exec_sub where exec_sub.ticket_id= ipcenter_ticket.ticket_id and exec_sub.status not in ('AUTO_ABORTED') and (exec_sub.creator_id is NULL OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipcal') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = 'ipautomata') OR exec_sub.creator_id = (select LoginID from auth.LOGIN where Username = @automataid) ) group by exec_sub.ticket_id) as 'NumberOfAutoamta',
    
    (select ipslr_s.automata_resolved from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataResolved',
    (select ipslr_s.automata_failed from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataFailed',
    (select ipslr_s.automata_assisted from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataAssisted',
    (select ipslr_s.automata_escalated from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'AutomataEscalated',
    (select SEC_TO_TIME(ipslr_s.time_to_resolution) from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'Time_To_Resolution',
    (select SEC_TO_TIME(ipslr_s.time_to_respond) from IPslr.ticket_summary ipslr_s where ipslr_s.ticket_id=ipcenter_ticket.ticket_id LIMIT 1) as 'Time_To_Respond',
    ipcenter_ticket.priority as 'Priority',
    ipcenter_ticket.create_date as 'CreateDateTime',
    ipcenter_ticket.resolve_date as 'ResolveDateTime',
    ipcenter_ticket.CreateDate,
    ipcenter_ticket.CreateTimeHour,
    ipcenter_ticket.CreateMonth,
    (select ebond.externalTicketID from ebonding.ticket ebond where ebond.radarTicketID = ipcenter_ticket.ticket_id LIMIT 1) as 'ExternalTicket'

from 
    (
        select
            tkt_radar_resolved.ticket_id,
            tkt_radar_resolved.master_ticket_id,
            tkt_radar_resolved.description,
            IFNULL(tkt_radar_resolved.criticality_id,'POther') as 'priority',
            CONVERT_TZ(tkt_radar_resolved.create_date,'UTC','America/New_York') as 'create_date',
            CONVERT_TZ(tkt_radar_resolved.resolve_date,'UTC','America/New_York') as 'resolve_date', 
            tkt_radar_resolved.owner_id,
            tkt_radar_resolved.status_id,
            DATE_FORMAT(CONVERT_TZ(tkt_radar_resolved.create_date,'UTC','America/New_York'),'%d-%b') as 'CreateDate',
            DATE_FORMAT(CONVERT_TZ(tkt_radar_resolved.create_date,'UTC','America/New_York'),'%h %p') as 'CreateTimeHour',
            DATE_FORMAT(CONVERT_TZ(tkt_radar_resolved.create_date,'UTC','America/New_York'),'%M') as 'CreateMonth',
            SUBSTRING(tkt_radar_resolved.note,1,2000) as 'note',
            client.ClientName as 'ClientClientname'
        
        from 
        IPradar.tickets_resolved tkt_radar_resolved, auth.CLIENT client #,IPradar.ipmon_ticket_mapping tkt_radar_resolved_ipmon
    
        where 
            tkt_radar_resolved.client_id = client.ClientID
            #and tkt_radar_resolved_ipmon.ticket_id = tkt_radar_resolved.ticket_id
            and tkt_radar_resolved.description not like ('IPpm%')
            and tkt_radar_resolved.create_date >= @start_date
            and tkt_radar_resolved.create_date <= @end_date
            #and tkt_radar_resolved.master_ticket_id is NULL
            and client.ClientClientname != "IPsoft"
            #and tkt_radar_resolved.ticket_id = 122013
            #and tkt_radar_resolved_ipmon.host_name like ('PTC-WBINDB101%')
        
        Union
        
        select
            tkt_radar_open.ticket_id,
            tkt_radar_open.master_ticket_id,
            tkt_radar_open.description,
            IFNULL(tkt_radar_open.criticality_id,'POther') as 'priority',
            CONVERT_TZ(tkt_radar_open.create_date,'UTC','America/New_York') as 'create_date',
            CONVERT_TZ(tkt_radar_open.resolve_date,'UTC','America/New_York') as 'resolve_date',         
            tkt_radar_open.owner_id,
            tkt_radar_open.status_id,
            DATE_FORMAT(CONVERT_TZ(tkt_radar_open.create_date,'UTC','America/New_York'),'%d-%b') as 'CreateDate',
            DATE_FORMAT(CONVERT_TZ(tkt_radar_open.create_date,'UTC','America/New_York'),'%h %p') as 'CreateTimeHour',
            DATE_FORMAT(CONVERT_TZ(tkt_radar_open.create_date,'UTC','America/New_York'),'%M') as 'CreateMonth',
            SUBSTRING(tkt_radar_open.note,1,2000) as 'note',
            client.ClientName as 'ClientClientname'
        
        from 
        IPradar.tickets tkt_radar_open, auth.CLIENT client #,IPradar.ipmon_ticket_mapping tkt_radar_open_ipmon
        
        where 
            tkt_radar_open.client_id = client.ClientID 
            #and tkt_radar_open_ipmon.ticket_id =  tkt_radar_open.ticket_id
            and tkt_radar_open.description not like ('IPpm%')
            and tkt_radar_open.create_date >= @start_date
            and tkt_radar_open.create_date <= @end_date
            #and tkt_radar_open.master_ticket_id is NULL
            and client.ClientClientname != "IPsoft"
            #and tkt_radar_open.ticket_id = 122013
            #and tkt_radar_open_ipmon.host_name like ('PTC-WBINDB101%')
    ) ipcenter_ticket
) ticket_rawdata



 



