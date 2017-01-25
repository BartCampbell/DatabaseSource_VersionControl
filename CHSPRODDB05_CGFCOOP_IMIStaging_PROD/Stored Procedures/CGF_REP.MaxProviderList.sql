SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*


	exec [CGF_REP].[MaxProviderList] @ProviderMedicalGroupID = 9999 3949


*/
CREATE	PROC [CGF_REP].[MaxProviderList]
	@ProviderMedicalGroupID		int = null
AS

IF EXISTS 
(
	SELECT * FROM CGF.ResultsByMember rbm 
	INNER JOIN provider p ON rbm.ProviderID = p.providerid
	WHERE (rbm.ProviderMedicalGroupID = @ProviderMedicalGroupID OR (@ProviderMedicalGroupID IS NULL AND rbm.ProviderMedicalGroupID > 0))
)
BEGIN 
	SELECT 
		DISTINCT TOP 1 
			rbm.Providerid, 
			p.ProviderFullName,
			p.CustomerProviderID, 
			rbm.ProviderMedicalGroupID 
		
		--SELECT TOP 10 rbm.ProviderMedicalGroupID,* 
		FROM CGF.ResultsByMember rbm
			INNER JOIN provider p
				ON rbm.ProviderID = p.providerid
		WHERE (rbm.ProviderMedicalGroupID = @ProviderMedicalGroupID OR (@ProviderMedicalGroupID IS NULL AND rbm.ProviderMedicalGroupID > 0))
	ORDER BY p.ProviderFullName

END 
ELSE 
	SELECT 
		Providerid = null, 
		ProviderFullName = NULL,
		CustomerProviderID = null, 
		ProviderMedicalGroupID = null





GO
