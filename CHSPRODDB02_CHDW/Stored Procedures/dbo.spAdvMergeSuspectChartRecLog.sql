SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/12/2016
-- Description:	merges the stage to dim for advance SuspectChartRecLog 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeSuspectChartRecLog
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeSuspectChartRecLog]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.SuspectChartRecLog AS t
        USING
            ( SELECT    sp.[SuspectID] ,
                        us.[UserID] ,
                        ps.[Log_Date] ,
                        ps.[Log_Info]
              FROM      [stage].[SuspectChartRecLog_ADV] ps
                        LEFT OUTER JOIN [fact].[Suspect] sp ON sp.CentauriSuspectID = ps.CentauriSuspectID
                        LEFT OUTER JOIN [dim].[User] us ON us.CentauriUserID = ps.CentauriUserID
            ) AS s
        ON t.SuspectID = s.SuspectID
            AND t.UserID = s.UserID
            AND t.[Log_Date] = s.Log_Date
            AND t.[Log_Info] = s.[Log_Info]
        WHEN MATCHED THEN
            UPDATE SET
                    t.[Log_Date] = s.[Log_Date] ,
                    t.[Log_Info] = s.[Log_Info] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( SuspectID ,
                     [UserID] ,
                     [Log_Date] ,
                     [Log_Info]

                   )
            VALUES ( SuspectID ,
                     [UserID] ,
                     [Log_Date] ,
                     [Log_Info]
                   );

    END;     

GO
