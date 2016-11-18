SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for MemberClient
-- Usage:			
--		  EXECUTE dbo.spOECMergeMemberClient
-- =============================================
CREATE PROC [dbo].[spOECMergeMemberClient]
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
                FROM    stage.MemberClient s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.MemberID = m.MemberID
                                                         AND mc.ClientMemberID = s.ClientMemberID
                WHERE   mc.MemberClientID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberClient s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                  AND mc.MemberID = m.MemberID
        WHERE   mc.ClientMemberID <> s.ClientMemberID;

    END;     

GO
