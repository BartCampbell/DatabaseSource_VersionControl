SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO





CREATE VIEW [dbo].[MedicalRecordIMATdap] AS
SELECT	*
FROM	dbo.MedicalRecordIMA
WHERE	IMAEvidenceID IN (2, 3, 4, 6, 7, 10, 11, 12, 13)





GO
