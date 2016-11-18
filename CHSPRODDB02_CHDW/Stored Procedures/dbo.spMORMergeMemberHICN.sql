SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	07/28/2016
-- Description:	merges the stage to dim for MemberHICN
-- Usage:			
--		  EXECUTE dbo.spMORMergeMemberHICN
-- =============================================
CREATE PROC [dbo].[spMORMergeMemberHICN]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberHICN
                ( MemberID ,
                  HICN ,
                  RecordStartDate ,
			   RecordEndDate
	           )
                SELECT DISTINCT
                        m.MemberID,
				    s.HICN,
				    @CurrentDate,
				    '2999-12-31 00:00:00.000'
                FROM    stage.MemberHICN_MOR s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
				    LEFT JOIN dim.MemberHICN d ON d.MemberID = m.MemberID AND d.HICN = s.HICN
			 WHERE d.MemberHICNID IS NULL 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberHICN_MOR s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberHICN mc ON mc.MemberID = m.MemberID
        WHERE   mc.HICN <> s.HICN AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
