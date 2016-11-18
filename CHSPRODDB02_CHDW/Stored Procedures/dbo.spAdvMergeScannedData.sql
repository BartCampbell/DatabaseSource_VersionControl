SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance ScannedData 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeScannedData
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeScannedData]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.ScannedData AS t
        USING
            ( SELECT    sd.[CentauriScannedDataID] ,
                        sp.[SuspectID] ,
                        dt.[DocumentTypeID] ,
                        us.[UserID] ,
                        sd.[FileName] ,
                        sd.[dtInsert] ,
                        sd.[is_deleted] ,
                        sd.[CodedStatus]
              FROM      [stage].[ScannedData_ADV] sd
                        LEFT OUTER JOIN [fact].[Suspect] sp ON sp.CentauriSuspectID = sd.CentauriSuspectID
                        LEFT OUTER JOIN [dim].[User] us ON us.CentauriUserID = sd.CentauriUserID
                        LEFT OUTER JOIN dim.DocumentType dt ON dt.CentauriDocumentTypeID = sd.CentauriDocumentTypeID
            ) AS s
        ON t.CentauriScannedDataID = s.CentauriScannedDataID
        WHEN MATCHED AND ( ISNULL(t.[SuspectID], 0) <> ISNULL(s.[SuspectID],
                                                              0)
                           OR ISNULL(t.[DocumentTypeID], 0) <> ISNULL(s.[DocumentTypeID],
                                                              0)
                           OR ISNULL(t.[UserID], 0) <> ISNULL(s.[UserID], 0)
                           OR ISNULL(t.[FileName], '') <> ISNULL(s.[FileName],
                                                              '')
                           OR ISNULL(t.[dtInsert], '') <> ISNULL(s.[dtInsert],
                                                              '')
                           OR ISNULL(t.[is_deleted], 0) <> ISNULL(s.[is_deleted],
                                                              0)
                           OR ISNULL(t.[CodedStatus], 0) <> ISNULL(s.[CodedStatus],
                                                              0)
                         ) THEN
            UPDATE SET
                    t.[SuspectID] = s.[SuspectID] ,
                    t.[DocumentTypeID] = s.[DocumentTypeID] ,
                    t.[UserID] = s.[UserID] ,
                    t.[FileName] = s.[FileName] ,
                    t.[dtInsert] = s.[dtInsert] ,
                    t.[is_deleted] = s.[is_deleted] ,
                    t.[CodedStatus] = s.[CodedStatus] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriScannedDataID] ,
                     [SuspectID] ,
                     [DocumentTypeID] ,
                     [UserID] ,
                     [FileName] ,
                     [dtInsert] ,
                     [is_deleted] ,
                     [CodedStatus] 

                   )
            VALUES ( [CentauriScannedDataID] ,
                     [SuspectID] ,
                     [DocumentTypeID] ,
                     [UserID] ,
                     [FileName] ,
                     [dtInsert] ,
                     [is_deleted] ,
                     [CodedStatus] 
                   );

    END;     

GO
