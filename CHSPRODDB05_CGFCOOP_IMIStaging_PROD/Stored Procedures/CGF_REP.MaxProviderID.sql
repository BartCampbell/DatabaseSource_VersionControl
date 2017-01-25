SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxProviderID]
AS

SELECT TOP 1  p.providerID
	FROM cgf.ResultsByMember rbm
		INNER JOIN provider p
			ON rbm.ProviderID = p.ProviderID
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
	WHERE  rbm.IsDenominator = 1 
		AND rbm.MeasureMetricDesc = 'CDC-HbA1C Test'
	GROUP BY p.providerID
	ORDER BY COUNT(*) DESC

GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MaxProviderID] TO [db_ViewProcedures]
GO
