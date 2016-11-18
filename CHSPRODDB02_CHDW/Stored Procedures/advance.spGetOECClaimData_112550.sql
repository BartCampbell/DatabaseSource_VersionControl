SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Travis Parker
-- Create date:	08/21/2016
-- Description:	retrieves claim data for advance for the specified chart retrieval
-- Usage:			
--		  EXECUTE advance.spGetOECClaimData_112550 '001', 112550
-- =============================================
CREATE PROC [advance].[spGetOECClaimData_112550]
    @ProjectID VARCHAR(20) ,
    @CentauriClientID INT
AS
    SET NOCOUNT ON; 

--DECLARE @ProjectID VARCHAR(20) = '001' ,
--    @CentauriClientID INT = '112548'

    SELECT DISTINCT
            pc.ClientProviderID,
		  mc.ClientMemberID,
		  o.ChaseID,
		  o.DiagnosisCode,
		  o.ClaimID,
		  CONVERT(SMALLDATETIME,NULLIF(o.DOS_FromDate,'')) AS DOS_FromDate,
		  CONVERT(SMALLDATETIME,NULLIF(LEFT(o.DOS_ToDate,8),'')) AS DOS_ToDate,
		  CONVERT(BIT,CASE o.ICD_Indicator WHEN '10' THEN 1 WHEN '9' THEN 0 ELSE NULL END) AS IsICD10, op.OECProjectID
    FROM    fact.OEC o
            INNER JOIN dim.OECProject op ON op.OECProjectID = o.OECProjectID
            INNER JOIN dim.Client c ON c.ClientID = op.ClientID
            INNER JOIN dim.Member m ON o.MemberID = m.MemberID
		  INNER JOIN dim.MemberClient mc ON c.ClientID = mc.ClientID AND m.MemberID = mc.MemberID
		  INNER JOIN dim.Provider p ON o.ProviderID = p.ProviderID
		  INNER JOIN dim.ProviderClient pc ON c.ClientID = pc.ClientID AND p.ProviderID = pc.ProviderID
    WHERE   op.ProjectID = @ProjectID
            AND c.CentauriClientID = @CentauriClientID
		  AND LEN(o.DOS_ToDate) > 8

GO
