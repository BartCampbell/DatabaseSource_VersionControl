SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[MedicalRecordFPCGADOD] 
AS
SELECT  *
FROM    dbo.MedicalRecordFPCGA
WHERE   GestationalSource = 'Delivery Date'


GO
