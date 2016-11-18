SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for MemberContact
-- Usage:			
--		  EXECUTE dbo.sp834MergeMemberContact
-- =============================================
CREATE PROC [dbo].[sp834MergeMemberContact]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberContact
                ( MemberID ,
                  Phone ,
                  RecordStartDate ,
			   RecordEndDate
	           )
                SELECT DISTINCT
                        m.MemberID,
				    s.Phone,
				    @CurrentDate,
				    '2999-12-31 00:00:00.000'
                FROM    stage.MemberContact s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
				    LEFT JOIN dim.MemberContact d ON d.MemberID = m.MemberID AND d.Phone = s.Phone
			 WHERE d.MemberContactID IS NULL 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberContact s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberContact mc ON mc.MemberID = m.MemberID
        WHERE   mc.Phone <> s.Phone AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     


GO
