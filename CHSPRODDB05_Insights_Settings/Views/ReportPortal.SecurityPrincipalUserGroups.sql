SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [ReportPortal].[SecurityPrincipalUserGroups] AS 
WITH GroupBase AS
(
	SELECT	[group].value('@id', 'uniqueidentifier')ADGuid,
			[group].value('@description', 'varchar(256)') AS Descr,
			[group].value('@displayname', 'varchar(128)') AS DisplayName,
			[group].value('@domain', 'varchar(128)') AS DomainName,
			[group].value('@name', 'nvarchar(128)') AS [Name],
			[group].value('@samaccountname', 'nvarchar(128)') AS PrincipalName,
			[group].value('@samaccountname', 'nvarchar(128)') AS SamAccountName,
			RSP.PrincipalGuid AS UserPrincipalGuid,
			RSP.PrincipalID AS UserPrincipalID
	FROM	ReportPortal.SecurityPrincipals AS RSP
			CROSS APPLY ADInfo.nodes('/user') AS u([user])
			CROSS APPLY [user].nodes('./group') AS g([group])
)
SELECT	GB.ADGuid,
        GB.Descr,
        GB.DisplayName,
        GB.DomainName,
        GB.Name,
		RSP.PrincipalGuid,
		RSP.PrincipalID,
        GB.PrincipalName,
        GB.SamAccountName,
        GB.UserPrincipalGuid,
        GB.UserPrincipalID
FROM	ReportPortal.SecurityPrincipals AS RSP
		INNER JOIN GroupBase AS GB
				ON (
						GB.DomainName = RSP.DomainName OR
						GB.DomainName LIKE RSP.DomainName + '[.]%'
					) AND
					GB.PrincipalName = RSP.PrincipalName
;

GO
