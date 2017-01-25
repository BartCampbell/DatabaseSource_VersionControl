SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


Create PROC [CGF_REP].[MemberDataSourceList] 
AS

--SELECT DISTINCT mbr.DataSource
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN Member mbr
--			ON rbm.IHDSMemberID = mbr.IHDS_Member_Id
--	ORDER BY mbr.DataSource

SELECT DISTINCT DataSource
	FROM Member
	Order by DataSource



GO
