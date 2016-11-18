SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for MemberEligibility
-- Usage:			
--		  EXECUTE dbo.sp834MergeMemberEligibility
-- =============================================
CREATE PROC [dbo].[sp834MergeMemberEligibility]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        MERGE INTO fact.MemberEligibility AS t
        USING
            ( SELECT DISTINCT
                        m.MemberID ,
                        s.Payor ,
                        s.EffectiveStartDate ,
                        s.EffectiveEndDate
              FROM      stage.MemberEligibility s --20736
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
            ) AS s
        ON t.MemberID = s.MemberID
            AND s.Payor = t.Payor
            AND s.EffectiveStartDate = t.EffectiveStartDate
        WHEN MATCHED AND ( t.EffectiveEndDate <> s.EffectiveEndDate ) THEN
            UPDATE SET
                    t.EffectiveEndDate = s.EffectiveEndDate ,
                    t.LastUpdate = @CurrentDate
        WHEN NOT MATCHED BY TARGET THEN
            INSERT ( MemberID ,
                     Payor ,
                     EffectiveStartDate ,
                     EffectiveEndDate ,
                     CreateDate
                   )
            VALUES ( s.MemberID ,
                     s.Payor ,
                     s.EffectiveStartDate ,
                     s.EffectiveEndDate ,
                     @CurrentDate
                   );

    END;     

GO
