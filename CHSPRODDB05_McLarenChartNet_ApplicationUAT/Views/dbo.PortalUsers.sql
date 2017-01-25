SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[PortalUsers] AS 
SELECT	A.AbstractorID,
		A.AbstractorName AS AbstractorName,
		PU.FirstName,
		PU.LastName,
		PU.PortalUserID,
		PU.UserName
FROM	Framework.PortalUser AS PU
		LEFT OUTER JOIN dbo.Abstractor AS A
				ON PU.LastName + ', ' + PU.FirstName = A.AbstractorName
WHERE	PU.UserName NOT IN ('anonymous', 'Authenticated', 'training.testuser', 'admin')

GO
