SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for ScheduleType for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeScheduleType
-- =============================================
create PROCEDURE [dbo].[spAdvMergeScheduleType]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.ScheduleType AS t
        USING
            ( SELECT    [CentauriScheduleTypeID],
	[ScheduleType] 
              FROM      stage.ScheduleType_ADV
                        
            ) AS s
        ON t.CentauriScheduleTypeID = s.CentauriScheduleTypeID
        WHEN MATCHED AND ( ISNULL(t.[ScheduleType], '') <> ISNULL(s.[ScheduleType],
                                                              '')
                           ) THEN
            UPDATE SET
                    t.[ScheduleType] = s.[ScheduleType] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriScheduleTypeID] ,
                     [ScheduleType] 
                     
                   )
            VALUES ( [CentauriScheduleTypeID] ,
                     [ScheduleType] 
                   );

    END;     


GO
