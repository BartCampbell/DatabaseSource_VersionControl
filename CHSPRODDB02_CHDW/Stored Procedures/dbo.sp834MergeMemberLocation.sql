SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for MemberLocation
-- Usage:			
--		  EXECUTE dbo.sp834MergeMemberLocation
-- =============================================
CREATE PROC [dbo].[sp834MergeMemberLocation]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO dim.MemberLocation
                ( MemberID ,
                  Addr1 ,
                  City ,
                  State ,
                  Zip ,
                  RecordStartDate ,
                  RecordEndDate
	           )
                SELECT DISTINCT
                        m.MemberID ,
                        s.Addr1 ,
                        d.City ,
                        d.State ,
                        d.Zip ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.MemberLocation s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberLocation d ON d.MemberID = m.MemberID
                                                          AND d.Addr1 = s.Addr1
                                                          AND d.City = s.City
                                                          AND d.State = s.State
                                                          AND d.Zip = s.Zip
                WHERE   d.MemberLocationID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberLocation s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberLocation mc ON mc.MemberID = m.MemberID
        WHERE   ( mc.Addr1 <> s.Addr1
                  OR mc.City <> s.City
                  OR mc.State <> s.State
                  OR mc.Zip <> s.Zip
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     


GO
