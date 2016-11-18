SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves member HCC data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECMemberHCC '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECMemberHCC]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            mc.ClientMemberID,
		  o.HCC	  
    FROM    fact.OECMemberHCC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.Member m ON o.MemberID = m.MemberID
		  INNER JOIN dim.MemberClient mc ON c.ClientID = mc.ClientID AND m.MemberID = mc.MemberID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;


		  
GO
