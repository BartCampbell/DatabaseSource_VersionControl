SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets provider Schedule details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetProviderSchedule]
	-- Add the parameters for the stored procedure here
    --@CCI VARCHAR(20) , 
	   @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT COUNT(*) FROM S_ProviderOfficeSchedule - 68609
        SELECT  
		c.[ClientProviderOfficeScheduleID] AS CentauriProviderOfficeScheduleID,
		m.ProviderOffice_BK AS CentauriProviderOfficeID 		,
			 p.Project_BK AS  [CentauriProjectID],
      r.User_PK AS [CentauriLastUserID],
      ui.User_PK AS [CentauriScheduledUserID],
      y.ScheduleType_BK [CentauriScheduleTypeID]      ,
	           s.[Sch_Start],s.[Sch_End],s.[LastUpdated_Date],s.[followup],s.[AddInfo]
      	    FROM    dbo.H_ProviderOffice m  --42316
        INNER JOIN [dbo].[L_ProviderOfficeProviderOfficeSchedule] o ON o.H_ProviderOffice_RK = m.H_ProviderOffice_RK -- 68609
		INNER JOIN dbo.H_ProviderOfficeSchedule c ON o.H_ProviderOfficeSchedule_RK = c.H_ProviderOfficeSchedule_RK -- 68609
		INNER JOIN dbo.S_ProviderOfficeSchedule s ON s.H_ProviderOfficeSchedule_RK = c.H_ProviderOfficeSchedule_RK -- 68609
		LEFT OUTER JOIN dbo.L_ProviderOfficeScheduleScheduleType t ON t.H_ProviderOfficeSchedule_RK = o.H_ProviderOfficeSchedule_RK
		LEFT OUTER JOIN dbo.H_ScheduleType y ON y.H_ScheduleType_RK = t.H_ScheduleType_RK
		LEFT OUTER JOIN dbo.L_ProviderOfficeScheduleProject d ON d.H_ProviderOfficeSchedule_RK = o.H_ProviderOfficeSchedule_RK
		LEFT OUTER JOIN dbo.H_Project p  ON p.H_Project_RK = d.H_Project_RK
		LEFT OUTER JOIN dbo.L_ProviderOfficeScheduleUser u ON u.H_ProviderOfficeSchedule_RK = o.H_ProviderOfficeSchedule_RK
		LEFT OUTER JOIN dbo.H_User r ON r.H_User_RK = u.H_User_RK
		LEFT OUTER JOIN (SELECT a.H_ProviderOfficeSchedule_RK,b.User_PK FROM S_ProviderOfficeSchedule a INNER JOIN H_User b ON a.Sch_User_PK = b.ClientUserID) ui ON ui.H_ProviderOfficeSchedule_RK = s.H_ProviderOfficeSchedule_RK
        WHERE   s.LoadDate > @LoadDate;

    END;


	
	
GO
