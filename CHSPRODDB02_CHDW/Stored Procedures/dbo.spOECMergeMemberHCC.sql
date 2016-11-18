SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Travis Parker
-- Create date:	08/21/2016
-- Description:	merges the stage to fact for OEC Member HCCs
-- Usage:			
--		  EXECUTE dbo.spOECMergeMemberHCC
-- =============================================
CREATE PROC [dbo].[spOECMergeMemberHCC]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.OECMemberHCC AS t
        USING
            ( SELECT    m.MemberID ,
                        op.OECProjectID ,
                        o.HCC 
              FROM      stage.MemberHCC_OEC o
                        INNER JOIN dim.OECProject op ON op.CentauriOECProjectID = o.CentauriProjectID
                        INNER JOIN dim.Member m ON m.CentauriMemberID = o.CentauriMemberID
            ) AS s
        ON t.OECProjectID = s.OECProjectID
            AND t.MemberID = s.MemberID
		  AND t.HCC = s.HCC
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( MemberID ,
                     OECProjectID ,
                     HCC,
                     CreateDate ,
                     LastUpdate
                   )
            VALUES ( s.MemberID ,
                     s.OECProjectID ,
                     s.HCC,
                     @CurrentDate ,
                     @CurrentDate
                   );

    END;     



GO
