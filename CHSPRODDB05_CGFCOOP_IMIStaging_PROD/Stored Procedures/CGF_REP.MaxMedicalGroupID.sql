SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*




	EXEC [CGF_REP].[MaxMedicalGroupID] 'CCA_sCO'
	EXEC [CGF_REP].[MaxMedicalGroupID] 'CCA_ICO'

*/
CREATE	PROC [CGF_REP].[MaxMedicalGroupID]
	@Client				varchar(30) = NULL 
AS

--DECLARE @ProviderMedicalGroupID  int = NULL 

--IF @Client = 'CCA_ICO' BEGIN 
--SET @ProviderMedicalGroupID = 3781
--END 

SELECT TOP 1 ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
		MedicalGroupName = MAX(CASE WHEN ISNULL(pmg.MedicalGroupName,'') = '' THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END)
	FROM CGF.ResultsByMember rbm
		INNER JOIN cgf.DataRuns dr
			ON rbm.DataRunGuid = dr.DataRunGuid
			AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
		INNER JOIN (SELECT MAX(dr.EndSeedDate) EndSeedDate
						FROM cgf.ResultsByMember rbm
							INNER JOIN cgf.DataRuns dr
								ON rbm.DataRunGuid = dr.DataRunGuid
								AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
					) msd
			ON dr.EndSeedDate = msd.EndSeedDate
		LEFT JOIN ProviderMedicalGroup pmg
			ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
	WHERE  rbm.IsDenominator = 1 
		AND (pmg.Client = @Client OR (@Client IS NULL AND pmg.Client LIKE '%%'))
		--AND (rbm.ProviderMedicalGroupID = @ProviderMedicalGroupID OR (@ProviderMedicalGroupID IS NULL AND rbm.ProviderMedicalGroupID > 0))
	GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0)



--SELECT ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
--		MedicalGroupName = MAX(CASE WHEN ISNULL(pmg.MedicalGroupName,'') = '' THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END)
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN cgf.DataRuns dr
--			ON rbm.DataRunGuid = dr.DataRunGuid
--			AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
--		INNER JOIN (SELECT MAX(dr.EndSeedDate) EndSeedDate
--						FROM cgf.ResultsByMember rbm
--							INNER JOIN cgf.DataRuns dr
--								ON rbm.DataRunGuid = dr.DataRunGuid
--								AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM cgf.dataruns GROUP BY EndSeedDate)
--					) msd
--			ON dr.EndSeedDate = msd.EndSeedDate
--		LEFT JOIN ProviderMedicalGroup pmg
--			ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
--	WHERE  rbm.IsDenominator = 1 
--		AND pmg.Client = 'CCA_ICO'
--	GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0)

--	ORDER BY MedicalGroupName

GO
