SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MedicalRecordCOLNum] AS
	SELECT	*
	FROM	dbo.MedicalRecordCOL
	WHERE	EvidenceType = 'Numerator'
GO
