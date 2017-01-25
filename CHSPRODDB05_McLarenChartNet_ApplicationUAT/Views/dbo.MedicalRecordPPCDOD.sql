SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[MedicalRecordPPCDOD] AS
SELECT	*
FROM	dbo.MedicalRecordPPC
WHERE	NumeratorType IN ('Chart EDD', 'ChartEDD', 'DeliveryDate', 'Delivery Date', 'DOD')
GO
