SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberHICN based on spOECMergeMemberHICN
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberHICN
-- =============================================
CREATE PROCEDURE [dbo].[spAdvMergeMemberHICN]
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
                FROM    stage.MemberHICN_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberHICN mc ON mc.MemberID = m.MemberID
                                                         AND mc.HICN = s.HICN
                WHERE   mc.MemberHICNID IS NULL;



        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberHICN_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberHICN mc ON mc.MemberID = m.MemberID
        WHERE   mc.HICN <> s.HICN;

    END;     


GO
