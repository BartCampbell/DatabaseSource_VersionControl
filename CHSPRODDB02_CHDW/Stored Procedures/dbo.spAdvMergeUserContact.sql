SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for UserContact based on sp834MergeUserContact
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUserContact
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUserContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.UserContact
                ( [UserID] ,
                  [EmailAddress] ,
                  [sch_Tel] ,
                  [sch_Fax] ,
                  RecordStartDate ,
                  RecordEndDate 
	            )
                SELECT DISTINCT
                        m.UserID ,
                        s.[Email_Address] ,
                        s.[sch_Tel] ,
                        s.[sch_Fax] ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.UserContact_ADV s
                        INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                        LEFT JOIN dim.UserContact d ON d.UserID = m.UserID
                                                       AND ISNULL(d.[EmailAddress],
                                                              '') = ISNULL(s.[Email_Address],
                                                              '')
                                                       AND ISNULL(d.[sch_Tel],
                                                              '') = ISNULL(s.[sch_Tel],
                                                              '')
                                                       AND ISNULL(d.[sch_Fax],
                                                              '') = ISNULL(s.[sch_Fax],
                                                              '')
                WHERE   d.UserContactID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.UserContact_ADV s
                INNER JOIN dim.[User] m ON m.CentauriUserID = s.CentauriUserid
                INNER JOIN dim.UserContact mc ON mc.UserID = m.UserID
        WHERE   ( ISNULL(mc.[EmailAddress], '') <> ISNULL(s.[Email_Address],
                                                          '')
                  OR ISNULL(mc.[sch_Tel], '') <> ISNULL(s.[sch_Tel], '')
                  OR ISNULL(mc.[sch_Fax], '') <> ISNULL(s.[sch_Fax], '')
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
