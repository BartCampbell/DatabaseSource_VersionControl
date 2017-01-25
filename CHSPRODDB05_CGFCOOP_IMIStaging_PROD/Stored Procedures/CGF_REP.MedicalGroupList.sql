SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [CGF_REP].[MedicalGroupList]

AS

SELECT distinct ProviderMedicalGroupID = ISNULL(rbm.ProviderMedicalGroupID,0),
		MedicalGroupName = CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END
	FROM CGF.ResultsByMember rbm
		LEFT JOIN ProviderMedicalGroup pmg
			ON rbm.ProviderMedicalGroupID = pmg.ProviderMedicalGrouPID
	ORDER by CASE WHEN rbm.ProviderMedicalGroupID IS NULL THEN 'Undefined Medical Group' ELSE pmg.MedicalGroupName END
GO
