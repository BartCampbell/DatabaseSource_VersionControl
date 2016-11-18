SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/07/2016
-- Description:	merges the stage to dim for CodedSource for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeCodedSource
-- =============================================
CREATE PROC [dbo].[spAdvMergeCodedSource]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.CodedSource AS t
        USING
            ( SELECT    [CentauriCodedSourceID] ,
                        [CodedSource] ,
                        [sortOrder]
              FROM      stage.CodedSource_ADV
            ) AS s
        ON t.CentauriCodedSourceID = s.CentauriCodedSourceID
        WHEN MATCHED AND ( ISNULL(t.[CodedSource], '') <> ISNULL(s.[CodedSource],
                                                              '')
                           OR ISNULL(t.[sortOrder], 0) <> ISNULL(s.[sortOrder],
                                                              0)
                         ) THEN
            UPDATE SET
                    t.CodedSource = s.CodedSource ,
                    t.[sortOrder] = s.[sortOrder] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( CentauriCodedSourceID ,
                     CodedSource ,
                     [sortOrder]
                   )
            VALUES ( CentauriCodedSourceID ,
                     CodedSource ,
                     [sortOrder]
                   );

    END;     


GO
