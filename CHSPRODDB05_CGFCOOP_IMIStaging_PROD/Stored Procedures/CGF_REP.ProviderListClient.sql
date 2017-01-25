SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*


	[CGF_REP].[ProviderListClient] 'CCI'
	[CGF_REP].[ProviderListClient] 'Wellcare'

	grant execute on [CGF_REP].[ProviderListClient]  to public 


*/
CREATE    PROC [CGF_REP].[ProviderListClient]
(
	@Client		varchar(30) = NULL 
)
AS

IF (@Client = 'All Client')
BEGIN 

	SELECT DISTINCT rbm.Providerid, 
			p.ProviderFullName,
			p.CustomerProviderID
		FROM CGF.ResultsByMember rbm
			INNER JOIN CGF.DataRuns dr
				ON rbm.DataRunGuid = dr.DataRunGuid
			INNER JOIN provider p
				ON rbm.ProviderID = p.providerid
				AND rbm.Client = p.Client
	
	ORDER BY p.ProviderFullName

END 
ELSE 
BEGIN 

	SELECT DISTINCT rbm.Providerid, 
			p.ProviderFullName,
			p.CustomerProviderID
		FROM CGF.ResultsByMember rbm
			INNER JOIN CGF.DataRuns dr
				ON rbm.DataRunGuid = dr.DataRunGuid
			INNER JOIN provider p
				ON rbm.ProviderID = p.providerid
				AND rbm.Client = p.Client
		WHERE (rbm.Client = @Client OR (@Client IS NULL AND p.Client LIKE '%%'))
	ORDER BY p.ProviderFullName

END 




GO
