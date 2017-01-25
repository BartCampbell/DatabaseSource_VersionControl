SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [CGF_REP].[EnrollmentGroupDesc] 
AS

IF OBJECT_ID('tempdb..#res') IS NOT NULL 
	DROP TABLE #res

SELECT Rowid = IDentity(int,1,1),
		EnrollmentGroupDesc = CONVERT(VARCHAR(100),NULL)
	INTO #res

INSERT INTO #res
SELECT DISTINCT EnrollmentGroupDesc = ISNULL(rbm.EnrollmentGroupDesc,'Not Defined')
	FROM CGF.ResultsByMember rbm
	ORDER BY ISNULL(rbm.EnrollmentGroupDesc,'Not Defined')

SELECT * 
	from #res
	ORDER BY Rowid

	
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[EnrollmentGroupDesc] TO [db_ViewProcedures]
GO
