SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Result].[MeasureDetail_PCR_Classic] AS
SELECT	PCR.AdjProbability,
        PCR.Age,
        PCR.BaseWeight,
        PCR.BatchID,
        PCR.ClinCondID,
        PCR.DataRunID,
        PCR.DataSetID,
        PCR.DccWeight,
        PCR.DemoWeight,
        PCR.DSEntityID,
        PCR.DSMemberID,
        PCR.Gender,
        PCR.HClinCondWeight,
        PCR.OwnerID,
		RMD.PayerID,
		RMD.PopulationID,
        PPL.ProductLineID,
        PCR.ResultRowGuid,
        PCR.ResultRowID,
        PCR.SourceRowGuid,
        PCR.SourceRowID,
        PCR.SurgeryWeight,
        PCR.TotalWeight,
        PCR.Variance
FROM	Result.MeasureDetail_PCR AS PCR
		INNER JOIN Result.MeasureDetail AS RMD
				ON PCR.SourceRowGuid = RMD.ResultRowGuid
		INNER JOIN Product.ProductLines AS PPL
				ON RMD.BitProductLines & PPL.BitValue > 0

GO
