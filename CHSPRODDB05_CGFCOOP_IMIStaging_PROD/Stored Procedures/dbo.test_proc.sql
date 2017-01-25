SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [dbo].[test_proc]

as

IF OBJECT_ID('tempdb..#prov') IS NOT NULL 
	DROP TABLE #prov

SELECT c.ServicingProviderID, COUNT(*) ProvClaimCount
	INTO #prov 
	FROM claim c
	GROUP BY c.ServicingProviderID

IF OBJECT_ID('tempdb..#res') IS NOT NULL 
	DROP TABLE #res

SELECT pmg.MedicalGroupName, COUNT(*) MbrCnt, AVG(ph.RetroRiskScore) AvgRisk
	INTO #res
	FROM PCPProfile.PCPProfileHdr AS ph
		INNER JOIN provider AS p
			ON p.ProviderID = ph.ProviderID
		INNER JOIN member m
			ON ph.MemberID = m.MemberID
		INNER JOIN dbo.ProviderMedicalGroup pmg
			ON ph.ProviderID = pmg.ProviderID
	WHERE m.Gender = 'F'
	GROUP by pmg.MedicalGroupName
	ORDER BY pmg.MedicalGroupName

SELECT r.*
	FROM #res r
	ORDER BY r.MedicalGroupName


IF OBJECT_ID('tempdb..#prov') IS NOT NULL 
	DROP TABLE #prov
IF OBJECT_ID('tempdb..#res') IS NOT NULL 
	DROP TABLE #res

GO
