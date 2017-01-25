SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [ReportPortal].[SecurityPrincipalUsers] AS 
SELECT	RSP.ADGuid,
		[user].value('@badlogoncount', 'int') AS BadLogonCount,
		[user].value('@description', 'varchar(256)') AS Descr,
		[user].value('@displayname', 'varchar(128)') AS DisplayName,
		[user].value('@email', 'nvarchar(256)') AS Email,
		[user].value('@firstname', 'nvarchar(64)') AS FirstName,
		[user].value('@lastname', 'nvarchar(64)') AS LastName,
		[user].value('@name', 'nvarchar(128)') AS [Name],
		[user].value('@phone', 'nvarchar(256)') AS Phone,
		RSP.PrincipalGuid,
		RSP.PrincipalID,
		[user].value('@samaccountname', 'nvarchar(128)') AS [SamAccountName],
		[user].value('@userprincipalname', 'nvarchar(128)') AS [UserPrincipalName]
FROM	ReportPortal.SecurityPrincipals AS RSP
		CROSS APPLY ADInfo.nodes('/user') AS u([user])
GO
