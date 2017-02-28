SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- =============================================
-- Author:		Travis Parker
-- Create date:	08/01/2016
-- Description:	merges the stage to dim for MemberClient
-- Usage:			
--		  EXECUTE dbo.spMMRMergeMemberClient
-- =============================================
CREATE PROC [dbo].[spMMRMergeMemberClient]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberClient
                ( MemberID ,
                  ClientID ,
                  ClientMemberID,
			   RecordStartDate,
			   RecordEndDate
	           )
                SELECT DISTINCT
                        m.MemberID ,
                        c.ClientID ,
                        ISNULL(s.ClientMemberID,''),
				    @CurrentDate,
				    '2999-12-31 00:00:00.000'
                FROM    stage.MemberClient_MMR s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.MemberID = m.MemberID
                                                         AND mc.ClientMemberID = ISNULL(s.ClientMemberID,'')
                WHERE   mc.MemberClientID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberClient_MMR s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                INNER JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                  AND mc.MemberID = m.MemberID
        WHERE   mc.ClientMemberID <> ISNULL(s.ClientMemberID,'') AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     


GO
