SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberLocation based on dbo.sp834MergeMemberLocation
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberLocation
-- =============================================
CREATE PROC [dbo].[spAdvMergeMemberLocation]
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
                  LocationType ,
                  RecordStartDate ,
                  RecordEndDate
	            )
                SELECT DISTINCT
                        m.MemberID ,
                        s.Addr1 ,
                        s.City ,
                        s.State ,
                        s.Zip ,
                        s.LocationType ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.MemberLocation_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN dim.MemberLocation d ON d.MemberID = m.MemberID
                                                          AND ISNULL(d.Addr1,
                                                              '') = ISNULL(s.Addr1,
                                                              '')
                                                          AND ISNULL(d.City,
                                                              '') = ISNULL(s.City,
                                                              '')
                                                          AND ISNULL(d.State,
                                                              '') = ISNULL(s.State,
                                                              '')
                                                          AND ISNULL(d.Zip, '') = ISNULL(s.Zip,
                                                              '')
                                                          AND ISNULL(d.LocationType,
                                                              '') = ISNULL(s.LocationType,
                                                              '')
                WHERE   d.MemberLocationID IS NULL; 

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
        FROM    stage.MemberLocation_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN dim.MemberLocation mc ON mc.MemberID = m.MemberID  AND ISNULL(mc.LocationType, '') = ISNULL(s.LocationType, '')
        WHERE   ( ISNULL(mc.Addr1, '') <> ISNULL(s.Addr1, '')
                  OR ISNULL(mc.City, '') <> ISNULL(s.City, '')
                  OR ISNULL(mc.State, '') <> ISNULL(s.State, '')
                  OR ISNULL(mc.Zip, '') <> ISNULL(s.Zip, '')
                 
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
