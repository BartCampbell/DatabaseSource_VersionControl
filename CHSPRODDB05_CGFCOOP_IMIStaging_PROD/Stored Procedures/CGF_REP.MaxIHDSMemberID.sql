SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create PROC [CGF_REP].[MaxIHDSMemberID]
AS

SELECT TOP 1 IHDS_Member_ID = IHDSMemberID
	FROM cgf.ResultsByMember rbm
	WHERE rbm.IsDenominator = 1
		AND rbm.IsNumerator = 0
	GROUP BY IHDSMemberID
	ORDER BY COUNT(*) desc

GO
