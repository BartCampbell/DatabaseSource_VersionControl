SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberClient based on spOECMergeMemberClient
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberClient
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeMemberClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberClient
                ( MemberID ,
                  ClientID ,
                  ClientMemberID
	           )
                SELECT DISTINCT
                        m.MemberID ,
                        c.ClientID ,
                        s.ClientMemberID
                FROM    stage.MemberClient_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.MemberID = m.MemberID
                                                         AND mc.ClientMemberID = s.ClientMemberID
                WHERE   mc.MemberClientID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberClient_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                  AND mc.MemberID = m.MemberID
        WHERE   mc.ClientMemberID <> s.ClientMemberID;

    END;     

GO
