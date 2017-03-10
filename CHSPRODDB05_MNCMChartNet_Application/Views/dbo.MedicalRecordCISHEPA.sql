SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[MedicalRecordCISHEPA] AS

SELECT  *
FROM    dbo.MedicalRecordCIS
WHERE	CIS_ImmunizationType IN ('Hepatitis A')
AND		(CIS_ExclContrFlag IS NULL OR CIS_ExclContrFlag = 0)




GO
