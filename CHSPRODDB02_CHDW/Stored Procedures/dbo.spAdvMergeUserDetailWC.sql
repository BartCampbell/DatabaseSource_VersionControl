SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/19/2016
-- Description:	merges the stage to dim for UserDetail 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUserDetail
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUserDetailWC]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    


        INSERT  INTO [dim].[UserDetail]
                ( [UserID] ,
                  [RemovedDate] ,
                  [IsAdmin] ,
                  [IsScanTech] ,
                  [IsScheduler] ,
                  [IsReviewer] ,
                  [IsQA] ,
                  [IsHRA] ,
                  [IsActive] ,
                  [only_work_selected_hours] ,
                  [only_work_selected_zipcodes] ,
                  [deactivate_after] ,
                  [linked_provider_id] ,
                  [ProviderID] ,
                  [IsClient] ,
                  [IsSchedulerSV] ,
                  [IsScanTechSV] ,
                  [IsChangePasswordOnFirstLogin] ,
                  [isQCC] ,
                  [willing2travell] ,
                  [linked_scheduler_user_pk] ,
                  [EmploymentStatus] ,
                  [EmploymentAgency] ,
                  [isAllowDownload] ,
                  CoderLevel ,
                  IsSchedulerManager ,
                  [RecordStartDate] ,
                  [RecordEndDate]
                )
                SELECT DISTINCT
                        m.[UserID] ,
                        s.[RemovedDate] ,
                        s.[IsAdmin] ,
                        s.[IsScanTech] ,
                        s.[IsScheduler] ,
                        s.[IsReviewer] ,
                        s.[IsQA] ,
                        s.[IsHRA] ,
                        s.[IsActive] ,
                        s.[only_work_selected_hours] ,
                        s.[only_work_selected_zipcodes] ,
                        s.[deactivate_after] ,
                        s.[linked_provider_id] ,
                        p.[ProviderID] ,
                        s.[IsClient] ,
                        s.[IsSchedulerSV] ,
                        s.[IsScanTechSV] ,
                        s.[IsChangePasswordOnFirstLogin] ,
                        s.[isQCC] ,
                        s.[willing2travell] ,
                        s.[linked_scheduler_user_pk] ,
                        s.[EmploymentStatus] ,
                        s.[EmploymentAgency] ,
                        s.[isAllowDownload] ,
                        s.CoderLevel ,
                        s.IsSchedulerManager ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.UserDetail_ADV s
                        INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                        LEFT OUTER JOIN dim.Provider p ON p.CentauriProviderID = s.CentauriProviderID
                        LEFT JOIN dim.UserDetail d ON d.UserID = m.UserID
                                                      AND ISNULL(d.[RemovedDate],
                                                              '') = ISNULL(s.[RemovedDate],
                                                              '')
                                                      AND ISNULL(d.[IsAdmin],
                                                              0) = ISNULL(s.[IsAdmin],
                                                              0)
                                                      AND ISNULL(d.[IsScanTech],
                                                              0) = ISNULL(s.[IsScanTech],
                                                              0)
                                                      AND ISNULL(d.[IsScheduler],
                                                              0) = ISNULL(s.[IsScheduler],
                                                              0)
                                                      AND ISNULL(d.[IsReviewer],
                                                              0) = ISNULL(s.[IsReviewer],
                                                              0)
                                                      AND ISNULL(d.[IsQA], 0) = ISNULL(s.[IsQA],
                                                              0)
                                                      AND ISNULL(d.[IsHRA], 0) = ISNULL(s.[IsHRA],
                                                              0)
                                                      AND ISNULL(d.[IsActive],
                                                              0) = ISNULL(s.[IsActive],
                                                              0)
                                                      AND ISNULL(d.[only_work_selected_hours],
                                                              0) = ISNULL(s.[only_work_selected_hours],
                                                              0)
                                                      AND ISNULL(d.[only_work_selected_zipcodes],
                                                              0) = ISNULL(s.[only_work_selected_zipcodes],
                                                              0)
                                                      AND ISNULL(d.[deactivate_after],
                                                              '') = ISNULL(s.[deactivate_after],
                                                              '')
                                                      AND ISNULL(d.[linked_provider_id],
                                                              '') = ISNULL(s.[linked_provider_id],
                                                              '')
                                                      AND ISNULL(d.[ProviderID],
                                                              '') = ISNULL(p.[ProviderID],
                                                              '')
                                                      AND ISNULL(d.[IsClient],
                                                              0) = ISNULL(s.[IsClient],
                                                              0)
                                                      AND ISNULL(d.[IsSchedulerSV],
                                                              0) = ISNULL(s.[IsSchedulerSV],
                                                              0)
                                                      AND ISNULL(d.[IsScanTechSV],
                                                              0) = ISNULL(s.[IsScanTechSV],
                                                              0)
                                                      AND ISNULL(d.[IsChangePasswordOnFirstLogin],
                                                              0) = ISNULL(s.[IsChangePasswordOnFirstLogin],
                                                              0)
                                                      AND ISNULL(d.[isQCC], 0) = ISNULL(s.[isQCC],
                                                              0)
                                                      AND ISNULL(d.[willing2travell],
                                                              0) = ISNULL(s.[willing2travell],
                                                              0)
                                                      AND ISNULL(d.[linked_scheduler_user_pk],
                                                              0) = ISNULL(s.[linked_scheduler_user_pk],
                                                              0)
                                                      AND ISNULL(d.[EmploymentStatus],
                                                              0) = ISNULL(s.[EmploymentStatus],
                                                              0)
                                                      AND ISNULL(d.[EmploymentAgency],
                                                              0) = ISNULL(s.[EmploymentAgency],
                                                              0)
                                                      AND ISNULL(d.[isAllowDownload],
                                                              0) = ISNULL(s.[isAllowDownload],
                                                              0)
                                                      AND ISNULL(d.[CoderLevel],
                                                              0) = ISNULL(s.[CoderLevel],
                                                              0)
                                                      AND ISNULL(d.[isSchedulerManager],
                                                              0) = ISNULL(s.[isSchedulerManager],
                                                              0)
                WHERE   d.UserDetailID IS NULL; 

		

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.UserDetail_ADV s
                INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                INNER JOIN dim.UserDetail mc ON mc.UserID = m.UserID
                LEFT OUTER JOIN dim.Provider p ON p.CentauriProviderID = s.CentauriProviderID
        WHERE   ( ISNULL(mc.[RemovedDate], '') <> ISNULL(s.[RemovedDate], '')
                  OR ISNULL(mc.[IsAdmin], 0) <> ISNULL(s.[IsAdmin], 0)
                  OR ISNULL(mc.[IsScanTech], 0) <> ISNULL(s.[IsScanTech], 0)
                  OR ISNULL(mc.[IsScheduler], 0) <> ISNULL(s.[IsScheduler], 0)
                  OR ISNULL(mc.[IsReviewer], 0) <> ISNULL(s.[IsReviewer], 0)
                  OR ISNULL(mc.[IsQA], 0) <> ISNULL(s.[IsQA], 0)
                  OR ISNULL(mc.[IsHRA], 0) <> ISNULL(s.[IsHRA], 0)
                  OR ISNULL(mc.[IsActive], 0) <> ISNULL(s.[IsActive], 0)
                  OR ISNULL(mc.[only_work_selected_hours], 0) <> ISNULL(s.[only_work_selected_hours],
                                                              0)
                  OR ISNULL(mc.[only_work_selected_zipcodes], 0) <> ISNULL(s.[only_work_selected_zipcodes],
                                                              0)
                  OR ISNULL(mc.[deactivate_after], '') <> ISNULL(s.[deactivate_after],
                                                              '')
                  OR ISNULL(mc.[linked_provider_id], '') <> ISNULL(s.[linked_provider_id],
                                                              '')
                  OR ISNULL(mc.[ProviderID], '') <> ISNULL(p.[ProviderID], '')
                  OR ISNULL(mc.[IsClient], 0) <> ISNULL(s.[IsClient], 0)
                  OR ISNULL(mc.[IsSchedulerSV], 0) <> ISNULL(s.[IsSchedulerSV],
                                                             0)
                  OR ISNULL(mc.[IsScanTechSV], 0) <> ISNULL(s.[IsScanTechSV],
                                                            0)
                  OR ISNULL(mc.[IsChangePasswordOnFirstLogin], 0) <> ISNULL(s.[IsChangePasswordOnFirstLogin],
                                                              0)
                  OR ISNULL(mc.[isQCC], 0) <> ISNULL(s.[isQCC], 0)
                  OR ISNULL(mc.[willing2travell], 0) <> ISNULL(s.[willing2travell],
                                                              0)
                  OR ISNULL(mc.[linked_scheduler_user_pk], 0) <> ISNULL(s.[linked_scheduler_user_pk],
                                                              0)
                  OR ISNULL(mc.[EmploymentStatus], 0) <> ISNULL(s.[EmploymentStatus],
                                                              0)
                  OR ISNULL(mc.[EmploymentAgency], 0) <> ISNULL(s.[EmploymentAgency],
                                                              0)
                  OR ISNULL(mc.[isAllowDownload], 0) <> ISNULL(s.[isAllowDownload],
                                                              0)
                  OR ISNULL(mc.[CoderLevel], 0) <> ISNULL(s.[CoderLevel], 0)
                  OR ISNULL(mc.[isSchedulerManager], 0) <> ISNULL(s.[isSchedulerManager],
                                                              0)
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
