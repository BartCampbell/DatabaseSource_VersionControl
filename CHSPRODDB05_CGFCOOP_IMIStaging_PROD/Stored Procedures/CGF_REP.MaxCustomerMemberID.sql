SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE	PROC [CGF_REP].[MaxCustomerMemberID]
AS

SELECT TOP 1 CustomerMemberID = SUBSTRING(CustomerMemberID,0,LEN(CustomerMemberID)-2)
	FROM cgf.ResultsByMember rbm
	WHERE rbm.IsDenominator = 1
		AND rbm.IsNumerator = 0
	GROUP BY CustomerMemberID
	ORDER BY COUNT(*) desc
GO
