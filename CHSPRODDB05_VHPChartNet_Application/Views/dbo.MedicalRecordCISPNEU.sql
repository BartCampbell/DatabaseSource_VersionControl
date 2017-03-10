SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[MedicalRecordCISPNEU] AS

SELECT  *
FROM    dbo.MedicalRecordCIS
WHERE	CIS_ImmunizationType IN ('Pneumococcal Conjugate')
AND		(CIS_ExclContrFlag IS NULL OR CIS_ExclContrFlag = 0)




GO
