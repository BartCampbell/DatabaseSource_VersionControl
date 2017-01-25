SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*


	exec [CGF_REP].[PopulationList] 

	GRANT EXECUTE ON [CGF_REP].[PopulationList] TO coop_ssrs 

*/
CREATE	PROC [CGF_REP].[PopulationList] 
AS

SET NOCOUNT ON 

DECLARE @Result TABLE ([id] int IDENTITY(1,1), [Description] varchar(50), PopulationValue varchar(50))

INSERT INTO @Result 
([Description], PopulationValue)
SELECT 
	'All', NULL 

INSERT INTO @Result
([Description], PopulationValue)
SELECT 
	DISTINCT ISNULL(rbm.PopulationDesc,'Not Defined'), ISNULL(rbm.PopulationDesc,'Not Defined')
FROM CGF.ResultsByMember rbm
ORDER BY ISNULL(rbm.PopulationDesc,'Not Defined')

--	Return 
SELECT * FROM @Result ORDER BY [ID]

	

GO
GRANT EXECUTE ON  [CGF_REP].[PopulationList] TO [coop_ssrs]
GO
