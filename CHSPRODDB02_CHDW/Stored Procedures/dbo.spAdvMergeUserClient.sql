SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for UserClient based on spOECMergeMemberClient
-- Usage:			
--		  EXECUTE dbo.spAdvMergeUserClient
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeUserClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.UserClient
                ( UserID ,
                  ClientID ,
                  ClientUserID
	            )
                SELECT DISTINCT
                        m.UserID ,
                        c.ClientID ,
                        s.ClientUserID
                FROM    stage.UserClient_ADV s
                        INNER JOIN dim.[User] m ON m.CentauriUserid = s.CentauriUserid
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.UserClient mc ON mc.ClientID = c.ClientID
                                                       AND mc.UserID = m.UserID
                                                       AND mc.ClientUserID = s.ClientUserID
                WHERE   mc.UserClientID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.UserClient_ADV s
                INNER JOIN dim.[USER] m ON m.CentauriUserID = s.CentauriUserid
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.UserClient mc ON mc.ClientID = c.ClientID
                                                AND mc.UserID = m.UserID
        WHERE   mc.ClientUserID <> s.ClientUserID;

    END;     

GO
