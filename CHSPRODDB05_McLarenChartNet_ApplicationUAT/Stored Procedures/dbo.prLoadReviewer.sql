SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[prLoadReviewer]
--***********************************************************************
--***********************************************************************
/*
Loads ChartNet Application table: Reviewer, from client provided list of Reviewers
*/
--***********************************************************************
--***********************************************************************
AS 
INSERT  INTO Reviewer
        (ReviewerName, LastName, FirstName, UserName
		)
        SELECT DISTINCT
                PU.LastName + ', ' + PU.FirstName AS ReviewerName,
				PU.LastName,
				PU.FirstName,
				PU.UserName
        FROM    Framework.PortalUser AS PU
                LEFT OUTER JOIN Framework.PortalUserRole AS PUR ON PU.PortalUserID = PUR.PortalUserID
                LEFT OUTER JOIN Framework.PortalRole AS PR ON PUR.PortalRoleID = PR.PortalRoleID
        WHERE   PU.LastName + ', ' + PU.FirstName NOT IN (SELECT DISTINCT
                                                              ReviewerName
                                                          FROM
                                                              dbo.Reviewer) AND
                PU.UserName NOT IN ('anonymous', 'Authenticated',
                                    'training.testuser', 'admin', 'sec')  AND
				PU.[Enabled] = 1
                --COMMENT OUT IF NECESSARY FOR IMPLEMENTATION---------------
				AND PR.[Name] IN ('Reviewers')
        ORDER BY 1




GO
GRANT EXECUTE ON  [dbo].[prLoadReviewer] TO [Support]
GO
