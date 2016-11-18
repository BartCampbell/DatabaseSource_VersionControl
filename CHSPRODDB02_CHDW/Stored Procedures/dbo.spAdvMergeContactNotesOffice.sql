SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance ContactNotesOffice 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeContactNotesOffice
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeContactNotesOffice]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.ContactNotesOffice AS t
        USING
            ( SELECT    cn.[CentauriContactNotesOfficeID] ,
                        pj.[ProjectID] ,
                        cn.[CentauriProviderOfficeID] ,
                        ci.[ContactNoteID] ,
                        cn.[ContactNoteText] ,
                        us.[UserID] ,
                        cn.[LastUpdated_Date] ,
                        cn.[contact_num] ,
                        cn.[followup] ,
                        cn.[IsResponded] ,
                        cn.[IsViewedByScheduler]
              FROM      [stage].[ContactNotesOffice_ADV] cn
                        LEFT OUTER JOIN [dim].[User] us ON us.CentauriUserID = cn.CentauriUserID
                        LEFT OUTER JOIN dim.ContactNote ci ON ci.CentauriContactNoteID = cn.CentauriContactNoteID
                        LEFT OUTER JOIN [dim].[ADVProject] pj ON pj.CentauriProjectID = cn.CentauriProjectID
            ) AS s
        ON t.CentauriContactNotesOfficeID = s.CentauriContactNotesOfficeID
        WHEN MATCHED AND ( ISNULL(t.[ProjectID], 0) <> ISNULL(s.[ProjectID], 0)
                           OR ISNULL(t.[CentauriProviderOfficeID], 0) <> ISNULL(s.[CentauriProviderOfficeID],
                                                              0)
                           OR ISNULL(t.[ContactNoteID], 0) <> ISNULL(s.[ContactNoteID],
                                                              0)
                           OR ISNULL(t.[ContactNoteText], '') <> ISNULL(s.[ContactNoteText],
                                                              '')
                           OR ISNULL(t.[UserID], 0) <> ISNULL(s.[UserID], 0)
                           OR ISNULL(t.[LastUpdated_Date], '') <> ISNULL(s.[LastUpdated_Date],
                                                              '')
                           OR ISNULL(t.[contact_num], 0) <> ISNULL(s.[contact_num],
                                                              0)
                           OR ISNULL(t.[followup], '') <> ISNULL(s.[followup],
                                                              '')
                           OR ISNULL(t.[IsResponded], 0) <> ISNULL(s.[IsResponded],
                                                              0)
                           OR ISNULL(t.[IsViewedByScheduler], 0) <> ISNULL(s.[IsViewedByScheduler],
                                                              0)
                         ) THEN
            UPDATE SET
                    t.[ProjectID] = s.[ProjectID] ,
                    t.[CentauriProviderOfficeID] = s.[CentauriProviderOfficeID] ,
                    t.[ContactNoteID] = s.[ContactNoteID] ,
                    t.[ContactNoteText] = s.[ContactNoteText] ,
                    t.[UserID] = s.[UserID] ,
                    t.[LastUpdated_Date] = s.[LastUpdated_Date] ,
                    t.[contact_num] = s.[contact_num] ,
                    t.[followup] = s.[followup] ,
                    t.[IsResponded] = s.[IsResponded] ,
                    t.[IsViewedByScheduler] = s.[IsViewedByScheduler] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriContactNotesOfficeID] ,
                     [ProjectID] ,
                     [CentauriProviderOfficeID] ,
                     [ContactNoteID] ,
                     [ContactNoteText] ,
                     [UserID] ,
                     [LastUpdated_Date] ,
                     [contact_num] ,
                     [followup] ,
                     [IsResponded] ,
                     [IsViewedByScheduler] 

                   )
            VALUES ( [CentauriContactNotesOfficeID] ,
                     [ProjectID] ,
                     [CentauriProviderOfficeID] ,
                     [ContactNoteID] ,
                     [ContactNoteText] ,
                     [UserID] ,
                     [LastUpdated_Date] ,
                     [contact_num] ,
                     [followup] ,
                     [IsResponded] ,
                     [IsViewedByScheduler] 
                   );

    END;     

GO
