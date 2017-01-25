SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*

	[CGF_REP].[ProviderListClientAll] 'All Client'

	[CGF_REP].[ProviderListClientAll] 'Aetna'
	[CGF_REP].[ProviderListClientAll] 'Wellcare'

	grant execute on [CGF_REP].[ProviderListClientAll]  to public 


*/
CREATE    PROC [CGF_REP].[ProviderListClientAll]
(
	@Client		varchar(30) = 'All Client' 
)
AS

DECLARE @Output TABLE (Providerid int, ProviderFullName varchar(100), CustomerProviderID varchar(30))


IF (@Client = 'All Client')
BEGIN 
	INSERT INTO @Output 
	(Providerid, ProviderFullName, CustomerProviderID)
	SELECT 
		Providerid = NULL,
		ProviderFullName = 'All Providers',
		CustomerProviderID = NULL 
		
	INSERT INTO @Output 
	(Providerid, ProviderFullName, CustomerProviderID)
	SELECT DISTINCT rbm.Providerid, 
			p.ProviderFullName,
			p.CustomerProviderID
		FROM CGF.ResultsByMember rbm
			INNER JOIN provider p
				ON rbm.ProviderID = p.providerid
				--AND rbm.Client = p.Client
	
	ORDER BY p.ProviderFullName

END 
ELSE 
BEGIN 
	INSERT INTO @Output 
	(Providerid, ProviderFullName, CustomerProviderID)
	SELECT 
		Providerid = NULL,
		ProviderFullName = 'All Providers',
		CustomerProviderID = NULL 
		
	INSERT INTO @Output 
	(Providerid, ProviderFullName, CustomerProviderID)
	SELECT DISTINCT rbm.Providerid, 
			p.ProviderFullName,
			p.CustomerProviderID
		FROM CGF.ResultsByMember rbm
			INNER JOIN provider p
				ON rbm.ProviderID = p.providerid
				--AND rbm.Client = p.Client
		WHERE (rbm.Client = @Client OR (@Client IS NULL AND p.Client LIKE '%%'))
	ORDER BY p.ProviderFullName

END 

--	Return 
SELECT * FROM @Output 





GO
