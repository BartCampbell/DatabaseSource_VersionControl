SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[MedicalRecordHPVNum] AS
SELECT	*
FROM	dbo.MedicalRecordHPV
WHERE	HPVEvidenceID IN (1, 3)





GO
