SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- =============================================
-- Author:		Travis Parker
-- Create date:	07/21/2016
-- Description:	merges the stage to dim for MemberPCP
-- Usage:			
--		  EXECUTE dbo.sp834MergeMemberPCP
-- =============================================
CREATE PROC [dbo].[sp834MergeMemberPCP]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
        INSERT  INTO fact.MemberPCP
                ( MemberID ,
                  ProviderID,
			   PCPEffectiveDate,
			   CreateDate,
			   LastUpdate
	           )
                SELECT DISTINCT
                        m.MemberID ,
                        p.ProviderID,
				    s.PCPEffectiveDate,
                        @CurrentDate ,
                        @CurrentDate
                FROM    stage.MemberPCP s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
				    INNER JOIN dim.Provider p ON p.CentauriProviderID = s.CentauriProviderID
                        LEFT JOIN fact.MemberPCP f ON f.MemberID = m.MemberID AND f.ProviderID = p.ProviderID AND f.PCPEffectiveDate = s.PCPEffectiveDate 
			 WHERE f.MemberPCPID IS NULL 


    END;     


GO
