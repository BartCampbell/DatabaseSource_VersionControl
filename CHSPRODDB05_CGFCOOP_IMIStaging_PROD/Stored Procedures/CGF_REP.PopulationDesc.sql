SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[PopulationDesc] 
AS

IF OBJECT_ID('tempdb..#res') IS NOT NULL 
	DROP TABLE #res

SELECT Rowid = IDentity(int,1,1),
		PopulationDesc = CONVERT(VARCHAR(100),NULL)
	INTO #res

INSERT INTO #res
SELECT DISTINCT PopulationDesc = ISNULL(rbm.PopulationDesc,'Not Defined')
	FROM CGF.ResultsByMember rbm
	ORDER BY ISNULL(rbm.PopulationDesc,'Not Defined')

SELECT * 
	from #res
	ORDER BY Rowid

	
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[PopulationDesc] TO [db_ViewProcedures]
GO
