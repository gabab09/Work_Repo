select
l.FirstName,
l.LastName,
l.StartDate,
l.EndDate,
l.Email,
d.Name,
#count(1)
office.Name
from
auth.LOGIN l, auth.DEPARTMENT d, auth.INTERNAL_LOGIN internal, auth.OFFICE office
where
l.LoginID = internal.LoginID
and internal.DepartmentID = d.DepartmentID
and internal.OfficeID = office.OfficeID
#and l.EndDate is NULL 
and l.EndDate >= "2018-09-01 23:59:59"
and l.EndDate <= "2018-09-31 23:59:59"
#group by d.Name
#,office.Name
#order by count(1) desc
