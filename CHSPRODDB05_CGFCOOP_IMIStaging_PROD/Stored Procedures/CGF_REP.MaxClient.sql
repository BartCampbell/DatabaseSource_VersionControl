SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MaxClient]
AS

SELECT Top 1 client
	FROM CGF.ResultsByMember rbm
	WHERE rbm.IsDenominator = 1 
	GROUP BY client
	ORDER BY COUNT(*) DESC

--select Client = MAX(Client)
--	FROM CGF.ClientList


GO
GRANT VIEW DEFINITION ON  [CGF_REP].[MaxClient] TO [db_ViewProcedures]
GO
