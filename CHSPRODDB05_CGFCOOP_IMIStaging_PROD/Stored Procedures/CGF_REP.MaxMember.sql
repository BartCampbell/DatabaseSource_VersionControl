SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxMember]
AS

SELECT TOP 1 CustomerMemberID
	FROM cgf.ResultsByMember rbm
	WHERE rbm.IsDenominator = 1
		AND rbm.IsNumerator = 0
	GROUP BY CustomerMemberID
	ORDER BY COUNT(*) desc

GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MaxMember] TO [db_ViewProcedures]
GO
