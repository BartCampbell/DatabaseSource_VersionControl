SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[ClientList] 
AS

--SELECT DISTINCT mbr.client
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN Member mbr
--			ON rbm.IHDSMemberID = mbr.IHDS_Member_Id
--	ORDER BY mbr.client

SELECT client
	FROM CGF.ClientList
	Order by Client
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[ClientList] TO [db_ViewProcedures]
GO
