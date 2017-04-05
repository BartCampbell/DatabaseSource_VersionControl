SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Qarr].[PLD_MemberInfo] AS
SELECT	CASE WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 0 AND 0 THEN '00'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 1 AND 4 THEN '01'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 5 AND 9 THEN '02'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 10 AND 14 THEN '03'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 15 AND 17 THEN '04'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 18 AND 19 THEN '05'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 20 AND 24 THEN '06'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 25 AND 29 THEN '07'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 30 AND 34 THEN '08'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 35 AND 39 THEN '09'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 40 AND 44 THEN '10'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 45 AND 49 THEN '11'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 50 AND 54 THEN '12'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 55 AND 59 THEN '13'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 60 AND 64 THEN '14'
			 WHEN Member.GetAgeAsOf(RDSMK.DOB, BDR.EndInitSeedDate) BETWEEN 65 AND 254 THEN '15'
			 ELSE '99'
			 END AS AgeGroup,
		REPLACE(dbo.LeadSpaces(CONVERT(varchar(4),COALESCE(CASE WHEN MBR.[State] = 'NY' THEN QCRN.RefNbr WHEN MBR.[State] <> 'NY' THEN QCRNO.RefNbr END, QCRND.RefNbr, '999')), 3), ' ', '0') AS CountyCode,
		MBR.CustomerMemberID,
		RDSMK.DataRunID, 
		RDSMK.DataSetID,
		RDSMK.DSMemberID,
		ISNULL(QHP.EligibilityID, QHP2.EligibilityID) AS EligiblityID,
		COALESCE(QHP.Hispanic, QHP2.Hispanic, '9') AS Ethnicity,
		RDSMK.IhdsMemberID,
		CASE WHEN COALESCE(QHP.MarketCoverage, QHP2.MarketCoverage, '') = '1' AND 
				  COALESCE(QHP.EnrollmentRoute, QHP2.EnrollmentRoute, '') = '1'
			 THEN '1'
			 WHEN COALESCE(QHP.MarketCoverage, QHP2.MarketCoverage) = '1' AND 
				  COALESCE(QHP.EnrollmentRoute, QHP2.EnrollmentRoute, '') <> '1'
			 THEN '2'
			 WHEN COALESCE(QHP.MarketCoverage, QHP2.MarketCoverage) IN ('2','3') AND 
				  COALESCE(QHP.EnrollmentRoute, QHP2.EnrollmentRoute, '') = '1'
			 THEN '3'
			 WHEN COALESCE(QHP.MarketCoverage, QHP2.MarketCoverage) IN ('2','3') AND 
				  COALESCE(QHP.EnrollmentRoute, QHP2.EnrollmentRoute, '') <> '1'
			 THEN '4'
			 ELSE '9'
			 END AS MarketplaceProduct,
		MBR.MemberID,
		COALESCE(QHP.MetalLevel, QHP2.MetalLevel, '9') AS MetalLevel,
		CASE ISNULL(QHP.Race, QHP2.Race)
			 WHEN '1' --White (QHP)
			 THEN '1' --White (QARR)
			 WHEN '2' --Black (QHP)
			 THEN '2' --Black (QARR)
			 WHEN '3' --Asian (QHP)
			 THEN '3' --Asian/Pacific Islander (QARR)
			 WHEN '4' --Native Hawaiian Or Other Pacific Islander (QHP)
			 THEN '3' --Asian/Pacific Islander (QARR)
			 WHEN '5' --American Indian or Alaska Native (QHP)
			 THEN '4' --American Indian/Alaskan Native (QARR)
			 WHEN '6' --Other (QHP)
			 THEN '5' --Other (QARR)
			 ELSE '9' --Unknown
			 END AS Race,
		CASE RDSMK.Gender WHEN 1 THEN '1' WHEN 0 THEN '2' ELSE '9' END AS ReportedGender,
		RIGHT(REPLACE(MBR.CustomerMemberID, '-', ''), 8) AS ReportedMemberID,
		CASE COALESCE(QHP.SpokenLanguage, QHP2.SpokenLanguage ,'9')
			 WHEN '1'
			 THEN '1'
			 WHEN '9'
			 THEN '9'
			 ELSE '2'
			 END AS SpokenLanguage
FROM	Result.DataSetMemberKey AS RDSMK WITH(NOLOCK)
		INNER JOIN dbo.Member AS MBR WITH(NOLOCK)
				ON MBR.CustomerMemberID = RDSMK.CustomerMemberID AND
					MBR.ihds_member_id = RDSMK.IhdsMemberID
		INNER JOIN Batch.DataRuns AS BDR WITH(NOLOCK)
				ON BDR.DataRunID = RDSMK.DataRunID
		OUTER APPLY (
						SELECT	TOP 1
								tMN.*
						FROM	Member.Enrollment AS tMN WITH(NOLOCK)
						WHERE	tMN.DSMemberID = RDSMK.DSMemberID AND
								(
									(tMN.BeginDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate) OR
									(tMN.EndDate BETWEEN BDR.BeginInitSeedDate AND BDR.EndInitSeedDate) OR
									(tMN.BeginDate < BDR.BeginInitSeedDate AND tMN.EndDate > BDR.EndInitSeedDate) OR
									(BDR.BeginInitSeedDate BETWEEN tMN.BeginDate AND tMN.EndDate) OR
									(BDR.EndInitSeedDate BETWEEN tMN.BeginDate AND tMN.EndDate)
								)
						ORDER BY tMN.EndDate DESC
					) AS MN
		LEFT OUTER JOIN dbo.QHPMemberInfo AS QHP WITH(NOLOCK)
				ON QHP.MemberID = MBR.MemberID AND
					QHP.EligibilityID = MN.EligibilityID
		OUTER APPLY (
						SELECT TOP 1 
								*
						FROM	dbo.QHPMemberInfo AS tQHP WITH(NOLOCK)
						WHERE	tQHP.MemberID = MBR.MemberID
					) QHP2
		LEFT OUTER JOIN Qarr.CountyReferenceNumbers AS QCRN WITH(NOLOCK)
				ON QCRN.County = MBR.County
		OUTER APPLY (
						SELECT TOP 1 
								*
						FROM	Qarr.CountyReferenceNumbers AS tQCRNO WITH(NOLOCK) 
						WHERE	tQCRNO.County LIKE '%OUTOFSTATE%'
					) AS QCRNO
		OUTER APPLY (
						SELECT TOP 1 
								* 
						FROM	Qarr.CountyReferenceNumbers AS tQCRND WITH(NOLOCK) 
						WHERE	tQCRND.County LIKE '%UNKNOWN%'
					) AS QCRND


GO
