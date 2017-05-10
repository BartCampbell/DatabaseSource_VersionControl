SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =================================================================================================================================
-- Author: Melody Jones	
-- Create date: 04/18/2017
-- Description:	Created to use for the healthplan parameter based off whom the user is. 
-- Version History	
-- Date			Name			Comments
-- 04/18/2017	Melody Jones	Inital create 
-- ==================================================================================================================================
CREATE PROC [CGF_REP].[HealthPlanDesc]
(
	@UserName VARCHAR(50) NULL,
	@AssociationEmployee BIT,
	@UserID INT
)
AS
BEGIN
--determine if user is association employee and populate @UserID so we dont have to filter on text email in main query
SELECT
        @UserID=u.UserID ,
        @AssociationEmployee = CASE WHEN u.AssociationEmployeeFlag = 1 THEN 1
                                  ELSE 0
                             END
    FROM [dbo].[ReportUserPlanCode] upc
    INNER JOIN [dbo].[ReportUsers] u 
	ON upc.UserID = u.UserID
    AND u.Email = @UserName

IF @AssociationEmployee = 0
    BEGIN 
	SELECT DISTINCT hp.HealthPlanName
    FROM [dbo].[HealthPlan] hp
	INNER JOIN ( SELECT DISTINCT
                    u.UserID ,
                    upc.PlanCode ,
                    u.Email ,
                    u.AssociationEmployeeFlag
                FROM [dbo].[ReportUserPlanCode] upc
                INNER JOIN [dbo].[ReportUsers] u 
					ON upc.UserID = u.UserID
                                        AND u.UserID = @userID
                                    ) users ON hp.CustomerHealthPlanID = users.PlanCode
	END
ELSE
	BEGIN
	SELECT DISTINCT hp.HealthPlanName
    FROM [dbo].[HealthPlan] hp
	INNER JOIN [dbo].[ReportUsers] u 
	ON @userID = u.UserID AND u.AssociationEmployeeFlag = 1
	END
END

GO
