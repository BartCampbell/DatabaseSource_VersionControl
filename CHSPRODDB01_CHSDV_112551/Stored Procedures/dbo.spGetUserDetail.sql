SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/02/2016
-- Description:	Gets User details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetUserDetail]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here

        SELECT  h.User_PK AS CentauriUserID ,
		s.RemovedDate,
                s.[IsAdmin] ,
	s.[IsScanTech] ,
	s.[IsScheduler] ,
	s.[IsReviewer] ,
	s.[IsQA],
	s.[IsHRA],
	s.[IsActive] ,
	s.[only_work_selected_hours] ,
	s.[only_work_selected_zipcodes] ,
	s.[deactivate_after] ,
	s.[linked_provider_id],
	g.Provider_BK AS CentauriProviderID ,
	s.[IsClient] ,
	s.[IsSchedulerSV],
	s.[IsScanTechSV] ,
	s.[IsChangePasswordOnFirstLogin] ,
	s.[isQCC] ,
	s.[willing2travell] ,
	s.[linked_scheduler_user_pk] ,
	s.[EmploymentStatus] ,
	s.[EmploymentAgency] ,
	s.[isAllowDownload] ,
           @CCI AS [ClientID] ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN dbo.S_UserDetails s ON s.H_User_RK = h.H_User_RK
				LEFT OUTER JOIN (SELECT a.H_User_RK,b.Provider_BK  FROM dbo.S_UserDetails a INNER JOIN dbo.H_Provider b ON a.linked_provider_pk = b.ClientProviderID WHERE ISNULL(a.linked_provider_pk ,'') <> '') AS g ON s.H_User_RK = g.H_User_RK
                AND s.LoadDate > @LoadDate;

    END;
GO
