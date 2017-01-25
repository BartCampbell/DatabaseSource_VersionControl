SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/*


	exec [CGF_REP].[ProviderListParm] @ProviderMedicalGroupID = 2715

*/
CREATE	PROC [CGF_REP].[ProviderListParm]
	@ProviderMedicalGroupID int = null
AS

SELECT distinct rbm.Providerid, 
		p.ProviderFullName,
		p.CustomerProviderID, 
		rbm.ProviderMedicalGroupID 
	FROM CGF.ResultsByMember rbm
		INNER JOIN provider p
			ON rbm.ProviderID = p.providerid
	WHERE (rbm.ProviderMedicalGroupID = @ProviderMedicalGroupID OR (@ProviderMedicalGroupID IS NULL AND rbm.ProviderMedicalGroupID > 0))
ORDER BY p.ProviderFullName

GO
