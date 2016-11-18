SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Travis Parker
-- Create date:	06/03/2016
-- Description:	retrieves member data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECMember '001', 112546
-- =============================================
CREATE PROC [advance].[spGetOECMember]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

    SELECT DISTINCT
            mh.HICN,
		  mc.ClientMemberID,
		  m.LastName,
		  m.FirstName,
		  CONVERT(DATE,CONVERT(VARCHAR,m.DOB)) DOB,
		  m.Gender,		  
		  CONVERT(DATE,o.Eff_Date) Eff_Date,
		  CONVERT(DATE,o.Exp_Date) Exp_Date		  
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.Member m ON o.MemberID = m.MemberID
		  INNER JOIN dim.MemberClient mc ON c.ClientID = mc.ClientID AND m.MemberID = mc.MemberID
		  LEFT JOIN dim.MemberHICN mh ON o.MemberHICNID = mh.MemberHICNID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID;


		  
GO
