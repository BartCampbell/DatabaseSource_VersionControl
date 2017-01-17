SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/19/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
--Update 09/27/2016 Cast linked_provider_pk as varchar PJ
--Update 10/11/2016 Using LS_ProviderMasterOffice PJ
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
	s.CoderLevel,
	s.IsSchedulerManager,
           @CCI AS [ClientID] ,
                s.LoadDate AS LoadDate
        FROM    [dbo].[H_User] h
                INNER JOIN dbo.S_UserDetails s ON s.H_User_RK = h.H_User_RK AND s.RecordEndDate IS NULL
				LEFT OUTER JOIN  ( SELECT d.Provider_PK,hp.Provider_BK,a.H_User_RK FROM dbo.L_ProviderMasterOffice l 
	INNER JOIN dbo.LS_ProviderMasterOffice d ON d.L_ProviderMasterOffice_RK = l.L_ProviderMasterOffice_RK AND d.RecordEndDate IS null
	INNER JOIN dbo.S_UserDetails a ON CAST(a.linked_provider_pk AS VARCHAR) = d.Provider_PK AND a.RecordEndDate IS NULL AND  ISNULL(a.linked_provider_pk ,'') <> ''
	INNER JOIN dbo.H_Provider hp ON hp.H_Provider_RK = l.H_Provider_RK )	AS g ON s.H_User_RK = g.H_User_RK
	
	--			(SELECT a.H_User_RK,b.Provider_BK  FROM dbo.S_UserDetails a INNER JOIN dbo.H_Provider b ON CAST(a.linked_provider_pk AS VARCHAR) = b.ClientProviderID WHERE a.RecordEndDate IS NULL AND  ISNULL(a.linked_provider_pk ,'') <> '') AS g ON s.H_User_RK = g.H_User_RK
         WHERE s.LoadDate > @LoadDate;

    END;

	

GO
