SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/09/2016
-- Description:	merges the stage to dim for UserPassword
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUserPassword
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUserPassword]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.UserPassword
                ( [Userid] ,
                  [Password] ,
                  [dtPassword] ,
                  RecordStartDate ,
                  RecordEndDate
	            )
                SELECT  m.[Userid] ,
                        s.[Password] ,
                        s.[dtPassword] ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.UserPassword_ADV s
                        INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                        LEFT JOIN dim.UserPassword d ON d.UserID = m.UserID
                                                        AND ISNULL(d.[Password],
                                                              '') = ISNULL(s.[Password],
                                                              '')
                                                        AND ISNULL(d.[dtPassword],
                                                              '') = ISNULL(s.[dtPassword],
                                                              '')
                WHERE   d.UserPasswordID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.UserPassword_ADV s
                INNER JOIN dim.[User] m ON m.CentauriUserID = s.CentauriUserid
                INNER JOIN dim.UserPassword mc ON mc.UserID = m.UserID
        WHERE   ( ISNULL(mc.[Password], '') <> ISNULL(s.[Password], '')
                  OR ISNULL(mc.[dtPassword], '') <> ISNULL(s.[dtPassword], '')
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
