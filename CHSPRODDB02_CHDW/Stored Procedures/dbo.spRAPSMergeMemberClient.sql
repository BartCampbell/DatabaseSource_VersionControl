SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	06/11/2016
-- Description:	merges the stage to dim for MemberClient
-- Usage:			
--		  EXECUTE dbo.spRAPSMergeMemberClient
-- =============================================
CREATE PROC [dbo].[spRAPSMergeMemberClient]
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
                        '' AS ClientMemberID
                FROM    stage.MemberClient_RAPS s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        INNER JOIN dim.Client c ON c.CentauriClientID = s.CentauriClientID
                        LEFT JOIN dim.MemberClient mc ON mc.ClientID = c.ClientID
                                                         AND mc.MemberID = m.MemberID
                                                         AND mc.ClientMemberID = s.ClientMemberID
                WHERE   mc.MemberClientID IS NULL;



    END;     


GO
