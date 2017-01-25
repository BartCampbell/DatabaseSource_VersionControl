SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*


	PopulationListNoNull
	exec [CGF_REP].[MaxPopulationNoNull] 'CCA_ICO'
	exec [CGF_REP].[MaxPopulationNoNull] 'CCA_SCO'


*/
CREATE	PROC [CGF_REP].[MaxPopulationNoNull] 
(
	@Client			varchar(30) = 'All Client' 
)
AS

SET NOCOUNT ON 

DECLARE @Result TABLE ([id] int IDENTITY(1,1), [Description] varchar(50), PopulationValue varchar(50))

INSERT INTO @Result
([Description], PopulationValue)
SELECT 
	DISTINCT TOP 1 ISNULL(rbm.PopulationDesc,'Not Defined'), ISNULL(rbm.PopulationDesc,'Not Defined')
FROM CGF.ResultsByMember rbm
WHERE (rbm.Client = @Client OR (@Client = 'All Client' AND rbm.Client LIKE '%%'))
ORDER BY ISNULL(rbm.PopulationDesc,'Not Defined')

--	Return 
SELECT * FROM @Result ORDER BY [ID]

	


GO
