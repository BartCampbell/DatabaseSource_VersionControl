SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for ScanningNotes for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeScanningNotes
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeScanningNotes]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ScanningNotes AS t
        USING
            ( SELECT    [CentauriScanningNotesID] ,
                        [Note_Text] ,
                        [IsCNA] ,
                        [LastUpdated]
              FROM      stage.ScanningNotes_ADV
            ) AS s
        ON t.CentauriScanningNotesID = s.CentauriScanningNotesID
        WHEN MATCHED AND ( ISNULL(t.[Note_Text], '') <> ISNULL(s.[Note_Text],
                                                              '')
                           OR ISNULL(t.[IsCNA], 0) <> ISNULL(s.[IsCNA], 0)
                           OR ISNULL(t.[LastUpdated], '') <> ISNULL(s.[LastUpdated],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.[Note_Text] = s.[Note_Text] ,
                    t.[IsCNA] = s.[IsCNA] ,
                    t.[LastUpdated] = s.[LastUpdated] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriScanningNotesID] ,
                     [Note_Text] ,
                     [IsCNA] ,
                     [LastUpdated]
                     
                   )
            VALUES ( [CentauriScanningNotesID] ,
                     [Note_Text] ,
                     [IsCNA] ,
                     [LastUpdated]
                   );

    END;     


GO
