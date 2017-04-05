SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Result].[MeasureDetail_PPV_PUCV_Classic] AS
SELECT	RMD.Age,
		RMD.AgeMonths,
		PPV_PUCV.BatchID,
        PPV_PUCV.DataRunID,
        PPV_PUCV.DataSetID,
        PPV_PUCV.DSEntityID,
        PPV_PUCV.DSMemberID,
        PPV_PUCV.ExpectedQty,
		ROUND(PPV_PUCV.ExpectedQty, 4) AS ExpectedQtyRounded,
		RMD.Gender,
        PPV_PUCV.MetricID,
		RMD.PayerID,
		RMD.PopulationID,
        PPV_PUCV.Ppv,
        PPV_PUCV.PpvBaseWeight,
        PPV_PUCV.PpvDemoWeight,
        PPV_PUCV.PpvHccWeight,
        PPV_PUCV.PpvTotalWeight,
		PPL.ProductLineID,
        PPV_PUCV.Pucv,
        PPV_PUCV.PucvBaseWeight,
        PPV_PUCV.PucvDemoWeight,
        PPV_PUCV.PucvHccWeight,
        PPV_PUCV.PucvTotalWeight,
        PPV_PUCV.Qty,
        PPV_PUCV.ResultRowGuid,
        PPV_PUCV.ResultRowID,
        PPV_PUCV.SourceRowGuid,
        PPV_PUCV.SourceRowID
FROM	Result.MeasureDetail_PPV_PUCV AS PPV_PUCV
		INNER JOIN Result.MeasureDetail AS RMD
				ON PPV_PUCV.SourceRowGuid = RMD.ResultRowGuid
		INNER JOIN Product.ProductLines AS PPL
				ON RMD.BitProductLines & PPL.BitValue > 0


GO
