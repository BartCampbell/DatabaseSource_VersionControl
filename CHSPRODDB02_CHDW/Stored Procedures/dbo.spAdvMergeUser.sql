SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for User for advance
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUser
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUser]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO dim.[User] AS t
        USING
            ( SELECT    [CentauriUserid] ,
                        [Username] ,
                        [sch_Name] ,
                        [FirstName] ,
                        [LastName] ,
                        [ismale]
              FROM      stage.User_ADV
            ) AS s
        ON t.CentauriUserID = s.CentauriUserid
        WHEN MATCHED AND ( ISNULL(t.[Username], '') <> ISNULL(s.[Username], '')
                           OR ISNULL(t.[sch_Name], '') <> ISNULL(s.[sch_Name],
                                                              '')
                           OR ISNULL(t.[FirstName], '') <> ISNULL(s.[FirstName],
                                                              '')
                           OR ISNULL(t.[LastName], '') <> ISNULL(s.[LastName],
                                                              '')
                           OR ISNULL(t.[ismale], 0) <> ISNULL(s.[ismale], 0)
                         ) THEN
            UPDATE SET
                    t.[CentauriUserid] = s.[CentauriUserid] ,
                    t.[Username] = s.[Username] ,
                    t.[sch_Name] = s.[sch_Name] ,
                    t.[FirstName] = s.[FirstName] ,
                    t.[LastName] = s.[LastName] ,
                    t.[ismale] = s.[ismale] ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( [CentauriUserid] ,
                     [Username] ,
                     [sch_Name] ,
                     [FirstName] ,
                     [LastName] ,
                     [ismale]
                     
                   )
            VALUES ( [CentauriUserid] ,
                     [Username] ,
                     [sch_Name] ,
                     [FirstName] ,
                     [LastName] ,
                     [ismale]
                   );

    END;     


GO
