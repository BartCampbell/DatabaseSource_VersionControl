SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxProviderFullName]
AS

SELECT TOP 1 p.ProviderFullName, providerID = MAX(p.providerID)
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
	GROUP BY p.ProviderFullName
	ORDER BY COUNT(*) DESC

GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MaxProviderFullName] TO [db_ViewProcedures]
GO
