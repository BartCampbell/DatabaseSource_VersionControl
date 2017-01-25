SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




CREATE VIEW [dbo].[MedicalRecordPPCPrenatal] AS
SELECT	*
FROM	dbo.MedicalRecordPPC
WHERE	NumeratorType IN ('Prenatal')


GO
