SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*



	exec [CGF_REP].[MaxEndSeedDate_mmddyyy]  

*/
CREATE PROC [CGF_REP].[MaxEndSeedDate_mmddyyy] AS

--SELECT EndSeedDate = MAX(dr.EndSeedDate)
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN CGF.DataRuns dr
--			ON rbm.DataRunGuid = dr.DataRunGuid
----			AND dr.CreatedDate in (SELECT MAX(CreatedDate) FROM CGF.dataruns GROUP BY EndSeedDate)
--	WHERE rbm.IsDenominator = 1

select EndSeedDate = CONVERT(varchar(10), MAX(EndSeedDate), 101) 
	from CGF.EndSeedDateList


GO
