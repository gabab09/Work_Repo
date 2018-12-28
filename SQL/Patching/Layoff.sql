select
l.FirstName,
l.LastName,
l.StartDate,
l.EndDate,
l.Email,
d.Name,
office.Name
from
auth.LOGIN l, auth.DEPARTMENT d, auth.INTERNAL_LOGIN internal, auth.OFFICE office
where
l.LoginID = internal.LoginID
and internal.DepartmentID = d.DepartmentID
and internal.OfficeID = office.OfficeID
and l.EndDate >= "2017-11-01 23:59:59"
and l.EndDate <= "2018-01-31 23:59:59"
order by d.Name,office.Name
