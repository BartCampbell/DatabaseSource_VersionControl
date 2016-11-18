SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/07/2016
-- Description:	merges the stage to dim for ContactNote for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeContactNote
-- =============================================
CREATE PROC [dbo].[spAdvMergeContactNote]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ContactNote AS t
        USING
            ( SELECT    [CentauriContactNoteID] ,
                        [ContactNote_Text] ,
                        [IsSystem] ,
                        [sortOrder] ,
                        [IsIssue] ,
                        [IsCNA] ,
                        [IsFollowup] ,
                        [Followup_days] ,
                        [IsActive] ,
                        [IsCopyCenter] ,
                        [IsRetro] ,
                        [IsProspective] ,
                        [IsDataIssue] ,
                        [AllowedAttempts]
              FROM      stage.ContactNote_ADV
            ) AS s
        ON t.CentauriContactNoteID = s.CentauriContactNoteID
        WHEN MATCHED AND ( ISNULL(t.[ContactNote_Text], '') <> ISNULL(s.[ContactNote_Text],
                                                              '')
                           OR ISNULL(t.[IsSystem], 0) <> ISNULL(s.[IsSystem],
                                                              0)
                           OR ISNULL(t.[sortOrder], 0) <> ISNULL(s.[sortOrder],
                                                              0)
                           OR ISNULL(t.[IsIssue], 0) <> ISNULL(s.[IsIssue], 0)
                           OR ISNULL(t.[IsCNA], 0) <> ISNULL(s.[IsCNA], 0)
                           OR ISNULL(t.[IsFollowup], 0) <> ISNULL(s.[IsFollowup],
                                                              0)
                           OR ISNULL(t.[Followup_days], 0) <> ISNULL(s.[Followup_days],
                                                              0)
                           OR ISNULL(t.[IsActive], 0) <> ISNULL(s.[IsActive],
                                                              0)
                           OR ISNULL(t.[IsCopyCenter], 0) <> ISNULL(s.[IsCopyCenter],
                                                              0)
                           OR ISNULL(t.[IsRetro], 0) <> ISNULL(s.[IsRetro], 0)
                           OR ISNULL(t.[IsProspective], 0) <> ISNULL(s.[IsProspective],
                                                              0)
                           OR ISNULL(t.[IsDataIssue], 0) <> ISNULL(s.[IsDataIssue],
                                                              0)
                           OR ISNULL(t.[AllowedAttempts], 0) <> ISNULL(s.[AllowedAttempts],
                                                              0)
                         ) THEN
            UPDATE SET
                    t.ContactNote_Text = s.ContactNote_Text ,
                    t.[IsSystem] = s.[IsSystem] ,
                    t.[sortOrder] = s.[sortOrder] ,
                    t.[IsIssue] = s.[IsIssue] ,
                    t.[IsCNA] = s.[IsCNA] ,
                    t.[IsFollowup] = s.[IsFollowup] ,
                    t.[Followup_days] = s.[Followup_days] ,
                    t.[IsActive] = s.[IsActive] ,
                    t.[IsCopyCenter] = s.[IsCopyCenter] ,
                    t.[IsRetro] = s.[IsRetro] ,
                    t.[IsProspective] = s.[IsProspective] ,
                    t.[IsDataIssue] = s.[IsDataIssue] ,
                    t.[AllowedAttempts] = s.[AllowedAttempts] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriContactNoteID ,
                     ContactNote_Text ,
                     [IsSystem] ,
                     [sortOrder] ,
                     [IsIssue] ,
                     [IsCNA] ,
                     [IsFollowup] ,
                     [Followup_days] ,
                     [IsActive] ,
                     [IsCopyCenter] ,
                     [IsRetro] ,
                     [IsProspective] ,
                     [IsDataIssue] ,
                     [AllowedAttempts]
                   )
            VALUES ( CentauriContactNoteID ,
                     ContactNote_Text ,
                     [IsSystem] ,
                     [sortOrder] ,
                     [IsIssue] ,
                     [IsCNA] ,
                     [IsFollowup] ,
                     [Followup_days] ,
                     [IsActive] ,
                     [IsCopyCenter] ,
                     [IsRetro] ,
                     [IsProspective] ,
                     [IsDataIssue] ,
                     [AllowedAttempts]
                   );

    END;     


GO
