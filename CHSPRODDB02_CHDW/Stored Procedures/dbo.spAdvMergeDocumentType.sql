SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/07/2016
-- Description:	merges the stage to dim for DocumentType for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeDocumentType
-- =============================================
CREATE PROC [dbo].[spAdvMergeDocumentType]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.DocumentType AS t
        USING
            ( SELECT    [CentauriDocumentTypeID] ,
                        [DocumentType] ,
                        [LastUpdated]
              FROM      stage.DocumentType_ADV
            ) AS s
        ON t.CentauriDocumentTypeID = s.CentauriDocumentTypeID
        WHEN MATCHED AND ( ISNULL(t.[DocumentType], '') <> ISNULL(s.[DocumentType],
                                                              '')
                           OR ISNULL(t.[LastUpdated], '') <> ISNULL(s.[LastUpdated],
                                                              '')
                         ) THEN
            UPDATE SET
                    t.DocumentType = s.DocumentType ,
                    t.[LastUpdated] = s.[LastUpdated] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriDocumentTypeID ,
                     DocumentType ,
                     [LastUpdated]
                   )
            VALUES ( CentauriDocumentTypeID ,
                     DocumentType ,
                     [LastUpdated]
                   );

    END;     


GO
