SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[ProviderList]

AS

SELECT distinct rbm.Providerid, 
		p.ProviderFullName,
		p.CustomerProviderID
	FROM CGF.ResultsByMember rbm
		INNER JOIN provider p
			ON rbm.ProviderID = p.providerid
Order by p.ProviderFullName
GO
GRANT VIEW DEFINITION ON  [CGF_REP].[ProviderList] TO [db_ViewProcedures]
GO
