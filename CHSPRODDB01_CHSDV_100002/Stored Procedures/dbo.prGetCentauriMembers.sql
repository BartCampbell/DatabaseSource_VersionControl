SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
-- ===============================================================================================================
-- Author:		Travis Parker
-- Create date:	05/09/2016
-- Description:	Returns CentauriMemberID and Hash value for members passed INSERT 
-- Name:			prGetCentauriMembers
-- USAGE:  

DECLARE @RC INT;
DECLARE @MemberList dbo.MemberTableType;

INSERT INTO @MemberList
   (
     ClientID,
     ClientMemberID,
     LoadDate,
     RecordSource
   )
       SELECT
            '100001' AS ClientID,
            'TPTest1235' AS ClientMemberID,
            GETDATE() AS LoadDate,
            'TravisParker' AS RecordSource; 

-- TODO: Set parameter values here.

CREATE TABLE #TempMembers
(
     CentauriMemberID INT,
     MemberHashKey    VARCHAR(50),
     ClientID         VARCHAR(100),
     ClientMemberID   VARCHAR(50)
);

INSERT INTO #TempMembers
EXECUTE @RC = dbo.prGetCentauriMembers
        @MemberList;
GO

SELECT
     *
FROM #TempMembers;

-- ===============================================================================================================
*/

CREATE PROCEDURE [dbo].[prGetCentauriMembers]
     @MemberList MEMBERTABLETYPE READONLY
AS
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO CHSDV.dbo.R_Member
           (
             ClientID,
             ClientMemberID,
             LoadDate,
             RecordSource
           )
               SELECT DISTINCT
                    l.ClientID,
                    l.ClientMemberID,
                    l.LoadDate,
                    l.RecordSource
               FROM  @MemberList AS l
                     LEFT JOIN CHSDV.dbo.R_Member AS r ON l.ClientMemberID = r.ClientMemberID
                                                    AND l.ClientID = r.ClientID
               WHERE r.CentauriMemberID IS NULL;

        SELECT
             r.CentauriMemberID,
		   r.MemberHashKey,
             r.ClientID,
             r.ClientMemberID
        FROM @MemberList AS l
             INNER JOIN CHSDV.dbo.R_Member AS r ON l.ClientMemberID = r.ClientMemberID
                                             AND l.ClientID = r.ClientID;
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

GO
