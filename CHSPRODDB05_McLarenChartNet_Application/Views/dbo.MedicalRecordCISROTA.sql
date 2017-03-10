SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[MedicalRecordCISROTA] AS

SELECT  *
FROM    dbo.MedicalRecordCIS
WHERE	CIS_ImmunizationType IN ('Rotavirus (Unknown Dosage)', 'Rotavirus 2-Dose', 'Rotavirus 3-Dose')
AND		(CIS_ExclContrFlag IS NULL OR CIS_ExclContrFlag = 0)





GO
