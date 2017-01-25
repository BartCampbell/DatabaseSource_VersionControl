SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Result].[MeasureDetail_EDU_Classic] AS
SELECT	EDU.BatchID,
        EDU.DataRunID,
        EDU.DataSetID,
        EDU.DSEntityID,
        EDU.DSMemberID,
        EDU.ExpectedQty,
        EDU.MetricID,
		RMD.PayerID,
		RMD.PopulationID,
        EDU.Ppv,
        EDU.PpvBaseWeight,
        EDU.PpvDemoWeight,
        EDU.PpvHccWeight,
        EDU.PpvTotalWeight,
		PPL.ProductLineID,
        EDU.Pucv,
        EDU.PucvBaseWeight,
        EDU.PucvDemoWeight,
        EDU.PucvHccWeight,
        EDU.PucvTotalWeight,
        EDU.Qty,
        EDU.ResultRowGuid,
        EDU.ResultRowID,
        EDU.SourceRowGuid,
        EDU.SourceRowID
FROM	Result.MeasureDetail_EDU AS EDU
		INNER JOIN Result.MeasureDetail AS RMD
				ON EDU.SourceRowGuid = RMD.ResultRowGuid
		INNER JOIN Product.ProductLines AS PPL
				ON RMD.BitProductLines & PPL.BitValue > 0
GO
