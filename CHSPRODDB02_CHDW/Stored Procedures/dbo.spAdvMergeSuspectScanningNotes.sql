SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance SuspectScanningNotes 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeSuspectScanningNotes
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeSuspectScanningNotes]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.SuspectScanningNotes AS t
        USING
            ( SELECT    sp.[SuspectID] ,
                        us.[UserID] ,
                        sn.[ScanningNotesId] ,
                        ps.[dtInsert]
              FROM      [stage].[SuspectScanningNotes_ADV] ps
                        LEFT OUTER JOIN [fact].[Suspect] sp ON sp.CentauriSuspectID = ps.CentauriSuspectID
                        LEFT OUTER JOIN [dim].[User] us ON us.CentauriUserID = ps.CentauriUserID
                        LEFT OUTER JOIN dim.ScanningNotes sn ON sn.CentauriScanningNotesID = ps.CentauriScanningNotesID
            ) AS s
        ON t.SuspectID = s.SuspectID
            AND t.ScanningNotesID = s.ScanningNotesID
        WHEN MATCHED AND ( ISNULL(t.[UserID], 0) <> ISNULL(s.[UserID], 0)
                           OR ISNULL(t.[dtInsert], '') <> ISNULL(s.[dtInsert],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.[UserID] = s.[UserID] ,
                    t.[dtInsert] = s.[dtInsert] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( SuspectID ,
                     UserID ,
                     ScanningNotesID ,
                     dtInsert

                   )
            VALUES ( SuspectID ,
                     UserID ,
                     ScanningNotesID ,
                     dtInsert
                   );

    END;     

GO
