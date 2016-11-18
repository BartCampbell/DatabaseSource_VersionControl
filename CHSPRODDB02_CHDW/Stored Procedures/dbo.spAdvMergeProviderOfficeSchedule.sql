SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance ProviderOfficeSchedule 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeProviderOfficeSchedule
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeProviderOfficeSchedule]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.ProviderOfficeSchedule AS t
        USING
            ( SELECT DISTINCT
                        ps.CentauriProviderOfficeScheduleID ,
                        ps.CentauriProviderOfficeID ,
                        pj.ProjectID ,
                        lu.UserID AS LastUserID ,
                        su.UserID AS ScheduledUserID ,
                        st.ScheduleTypeID ,
                        ps.Sch_Start ,
                        ps.Sch_End ,
                        ps.LastUpdated_Date ,
                        ps.followup ,
                        ps.AddInfo
              FROM      [stage].[ProviderSchedule_ADV] ps
                        LEFT OUTER JOIN [dim].[ADVProject] pj ON pj.CentauriProjectID = ps.CentauriProjectID
                        LEFT OUTER JOIN [dim].[ScheduleType] st ON st.CentauriScheduleTypeID = ps.CentauriScheduleTypeID
                        LEFT OUTER JOIN dim.[User] lu ON lu.CentauriUserID = ps.CentauriLastUserID
                        LEFT OUTER JOIN dim.[User] su ON su.CentauriUserID = ps.CentauriScheduledUserID
            ) AS s
        ON t.CentauriProviderOfficeScheduleID = s.CentauriProviderOfficeScheduleID
        WHEN MATCHED AND ( ISNULL(t.CentauriProviderOfficeScheduleID, 0) <> ISNULL(s.CentauriProviderOfficeScheduleID,0)
                           OR ISNULL(t.CentauriProviderOfficeID, 0) <> ISNULL(s.CentauriProviderOfficeID,0)
                           OR ISNULL(t.ProjectID, 0) <> ISNULL(s.ProjectID, 0)
                           OR ISNULL(t.LastUserID, 0) <> ISNULL(s.LastUserID,0)
                           OR ISNULL(t.ScheduledUserID, 0) <> ISNULL(s.ScheduledUserID,0)
                           OR ISNULL(t.ScheduleTypeID, 0) <> ISNULL(s.ScheduleTypeID,0)
                           OR ISNULL(t.Sch_Start, '') <> ISNULL(s.Sch_Start,'')
                           OR ISNULL(t.Sch_End, '') <> ISNULL(s.Sch_End, '')
                           OR ISNULL(t.LastUpdated_Date, '') <> ISNULL(s.LastUpdated_Date,'')
                           OR ISNULL(t.followup, '') <> ISNULL(s.followup, '')
                           OR ISNULL(t.AddInfo, '') <> ISNULL(s.AddInfo, '')
                         ) THEN
            UPDATE SET
                    t.CentauriProviderOfficeID = s.CentauriProviderOfficeID ,
                    t.ProjectID = s.ProjectID ,
                    t.LastUserID = s.LastUserID ,
                    t.ScheduledUserID = s.ScheduledUserID ,
                    t.ScheduleTypeID = s.ScheduleTypeID ,
                    t.Sch_Start = s.Sch_Start ,
                    t.Sch_End = s.Sch_End ,
                    t.LastUpdated_Date = s.LastUpdated_Date ,
                    t.followup = s.followup ,
                    t.AddInfo = s.AddInfo ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriProviderOfficeScheduleID ,
                     CentauriProviderOfficeID ,
                     ProjectID ,
                     LastUserID ,
                     ScheduledUserID ,
                     ScheduleTypeID ,
                     Sch_Start ,
                     Sch_End ,
                     LastUpdated_Date ,
                     followup ,
                     AddInfo 
                   )
            VALUES ( CentauriProviderOfficeScheduleID ,
                     CentauriProviderOfficeID ,
                     ProjectID ,
                     LastUserID ,
                     ScheduledUserID ,
                     ScheduleTypeID ,
                     Sch_Start ,
                     Sch_End ,
                     LastUpdated_Date ,
                     followup ,
                     AddInfo
                   );

    END;     
GO
