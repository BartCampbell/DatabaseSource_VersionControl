SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/01/2016
-- Description:	merges the stage to dim for MemberHICN
-- Usage:			
--		  EXECUTE dbo.spOECMergeMemberHICN
-- =============================================
CREATE PROC [dbo].[spOECMergeMemberHICN]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberHICN
                ( MemberID ,
                  HICN
	           )
                SELECT DISTINCT
                        m.MemberID ,
                        s.HICN
                FROM    stage.MemberHICN s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberHICN mc ON mc.MemberID = m.MemberID
                                                         AND mc.HICN = s.HICN
                WHERE   mc.MemberHICNID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberHICN s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberHICN mc ON mc.MemberID = m.MemberID
        WHERE   mc.HICN <> s.HICN;

    END;     

GO
