SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadAbstractor]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: Abstractor, from client provided list of abstractors
*/
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO Abstractor
        (AbstractorName, LastName, FirstName, UserName
        )
        SELECT DISTINCT
                PU.LastName + ', ' + PU.FirstName AS AbstractorName,
				PU.LastName,
				PU.FirstName,
				PU.UserName
        FROM    Framework.PortalUser AS PU
                LEFT OUTER JOIN Framework.PortalUserRole AS PUR ON PU.PortalUserID = PUR.PortalUserID
                LEFT OUTER JOIN Framework.PortalRole AS PR ON PUR.PortalRoleID = PR.PortalRoleID
        WHERE   PU.LastName + ', ' + PU.FirstName NOT IN (SELECT DISTINCT
                                                              AbstractorName
                                                          FROM
                                                              dbo.Abstractor) AND
                PU.UserName NOT IN ('anonymous', 'Authenticated',
                                    'training.testuser', 'admin', 'sec') AND
				PU.[Enabled] = 1
                --COMMENT OUT IF NECESSARY FOR IMPLEMENTATION---------------
				AND PR.[Name] IN ('Abstractors')
        ORDER BY 1


		


GO
GRANT EXECUTE ON  [dbo].[prLoadAbstractor] TO [Support]
GO
