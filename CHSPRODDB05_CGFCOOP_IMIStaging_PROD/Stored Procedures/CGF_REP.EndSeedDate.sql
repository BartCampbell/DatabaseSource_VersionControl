SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[EndSeedDate] AS

--SELECT EndSeedDate = MAX(dr.EndSeedDate)
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN CGF.DataRuns dr
--			ON rbm.DataRunGuid = dr.DataRunGuid
----			AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
--	WHERE rbm.IsDenominator = 1

select EndSeedDate 
	from CGF.EndSeedDateList
	ORDER BY EndSeedDate desc

GO
GRANT VIEW DEFINITION ON  [CGF_REP].[EndSeedDate] TO [db_ViewProcedures]
GO
