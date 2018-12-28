	SELECT DISTINCT i.name FROM IPadmin.ipmon i JOIN IPadmin.ipmonEntry iE ON iE.ipmonID = i.ipmonID JOIN auth.Services s ON s.ID = iE.ipDeployIPmonID JOIN auth.ServiceType st ON st.ID = s.ServiceType AND st.Name = 'IPmon' WHERE i.ipAdminEnabled = 1 AND s.IsActive = 1 ORDER BY i.name;