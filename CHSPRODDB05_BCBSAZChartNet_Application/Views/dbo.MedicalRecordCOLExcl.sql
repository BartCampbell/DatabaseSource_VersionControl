SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[MedicalRecordCOLExcl] AS

SELECT  *
FROM    dbo.MedicalRecordCOL
WHERE	EvidenceType = 'Exclusion'





GO
