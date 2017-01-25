SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [CGF_REP].[ClientListNull] 
AS


--	EXEC [CGF_REP].[ClientListNull] 

--SELECT DISTINCT mbr.client
--	FROM CGF.ResultsByMember rbm
--		INNER JOIN Member mbr
--			ON rbm.IHDSMemberID = mbr.IHDS_Member_Id
--	ORDER BY mbr.client


SELECT 
	Client = NULL 

UNION 

SELECT 
	Client
FROM CGF.ClientList


GO
