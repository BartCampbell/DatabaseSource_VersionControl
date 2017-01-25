SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxMedicalGroupName]
AS



SELECT TOP 1 ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
		MedicalGroupName = MAX(CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END)
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
		AND rbm.MeasureMetricDesc = 'CDC-HbA1C Test'
		AND rbm.ProviderMedicalGroupID IS NOT NULL 
	GROUP BY ISNULL(rbm.ProviderMedicalGroupID,0)

GO
