SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for AdvanceLocation for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeAdvanceLocation
-- =============================================
create PROCEDURE [dbo].[spAdvMergeAdvanceLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.AdvanceLocation AS t
        USING
            ( SELECT    [CentauriAdvanceLocationID],
	[Location] 
              FROM      stage.AdvanceLocation_ADV
                        
            ) AS s
        ON t.CentauriAdvanceLocationID = s.CentauriAdvanceLocationID
        WHEN MATCHED AND ( ISNULL(t.[Location], '') <> ISNULL(s.[Location],
                                                              '')
                           ) THEN
            UPDATE SET
                    t.[Location] = s.[Location] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriAdvanceLocationID] ,
                     [Location] 
                     
                   )
            VALUES ( [CentauriAdvanceLocationID] ,
                     [Location] 
                   );

    END;     


GO
