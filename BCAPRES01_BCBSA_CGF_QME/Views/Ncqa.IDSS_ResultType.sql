SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Ncqa].[IDSS_ResultType] AS
WITH HybridMeasures AS 
(
	SELECT	BSS.DataRunID,
			BDR.DataSetID,
			BSS.MeasureID,
			BSS.PayerID,
			BSS.PopulationID,
			BSS.ProductClassID,
			PPL.ProductLineID,
			RRT.ResultTypeID,
			BSS.SysSampleRate,
			BSS.SysSampleSize,
			CEILING((1 + BSS.SysSampleRate) * BSS.SysSampleSize) AS SysSampleTotSize 
	FROM	Batch.SystematicSamples AS BSS
			INNER JOIN Product.ProductLines AS PPL
					ON (BSS.BitProductLines & PPL.BitValue > 0) OR
						(BSS.BitProductLines = 0 AND BSS.ProductLineID = PPL.ProductLineID)                  
			INNER JOIN Batch.DataRuns AS BDR
					ON BSS.DataRunID = BDR.DataRunID
			INNER JOIN Result.ResultTypes AS RRT
					ON RRT.Abbrev = 'H'
	GROUP BY BSS.DataRunID,
			BDR.DataSetID,
			BSS.MeasureID,
			BSS.PayerID,
			BSS.PopulationID,
			BSS.ProductClassID,
			PPL.ProductLineID,
			RRT.ResultTypeID,
			BSS.SysSampleRate,
			BSS.SysSampleSize
),
AllMeasures AS 
(
	SELECT DISTINCT
			RMD.DataRunID,
			RMD.DataSetID,
			CONVERT(bit, CASE WHEN h.PayerID IS NULL AND h.DataRunID IS NOT NULL THEN 1 ELSE 0 END) AS HasAllPayers,
			RMD.MeasureID,
			RMD.PayerID,
			RMD.PopulationID, 
			RMD.ProductLineID,
			ISNULL(h.ResultTypeID, RMD.ResultTypeID) AS ResultTypeID,
			h.SysSampleRate,
			h.SysSampleSize,
			h.SysSampleTotSize
	FROM	Result.MeasureSummary AS RMD
			INNER JOIN Product.Payers AS PP
					ON RMD.PayerID = PP.PayerID
			INNER JOIN Product.ProductTypes AS PPT
					ON PP.ProductTypeID = PPT.ProductTypeID
			LEFT OUTER JOIN HybridMeasures AS h
					ON RMD.DataRunID = h.DataRunID AND
						RMD.DataSetID = h.DataSetID AND
						RMD.MeasureID = h.MeasureID AND
						(RMD.PayerID = h.PayerID OR h.PayerID IS NULL) AND
						RMD.PopulationID = h.PopulationID AND
						PPT.ProductClassID = h.ProductClassID AND
						RMD.ProductLineID = h.ProductLineID	
	WHERE	(RMD.ResultTypeID IN (SELECT ResultTypeID FROM Result.ResultTypes WHERE Abbrev = 'A'))
),
ResultsBase AS
(
SELECT	m.DataRunID,
        m.DataSetID,
		m.HasAllPayers,
        m.MeasureID,
        m.PayerID,
        m.PopulationID,
        m.ProductLineID,
        RRT.Abbrev AS ReportType,
        YEAR(BDR.EndInitSeedDate) AS ReportYear,
        m.ResultTypeID,
        ISNULL(m.SysSampleRate, 0) AS SysSampleRate,
        ISNULL(m.SysSampleSize, 0) AS SysSampleSize,
        ISNULL(m.SysSampleTotSize, 0) AS SysSampleTotSize
FROM	AllMeasures AS m
		INNER JOIN Result.ResultTypes AS RRT
				ON m.ResultTypeID = RRT.ResultTypeID
		INNER JOIN Batch.DataRuns AS BDR
				ON m.DataRunID = BDR.DataRunID
),
ResultsBaseToFullMeasureList AS 
(
	SELECT DISTINCT
			RB.DataRunID,
            RB.DataSetID,
			0 AS HasAllPayers,
			MM.MeasureID,
            RB.PayerID,
            RB.PopulationID,
            RB.ProductLineID,
            RB.ReportType,
            RB.ReportYear,
            RB.ResultTypeID
	FROM	ResultsBase AS RB
			INNER JOIN Batch.DataRuns AS BDR
					ON BDR.DataRunID = RB.DataRunID
			INNER JOIN Measure.Measures AS MM
					ON MM.MeasureSetID = BDR.MeasureSetID AND
						MM.IsEnabled = 1
	WHERE	RB.ResultTypeID = 1
)
SELECT	RB.DataRunID,
        RB.DataSetID,
		RB.HasAllPayers,
        RB.MeasureID,
        RB.PayerID,
        RB.PopulationID,
        RB.ProductLineID,
        RB.ReportType,
        RB.ReportYear,
        RB.ResultTypeID,
        RB.SysSampleRate,
        RB.SysSampleSize,
        RB.SysSampleTotSize
FROM	ResultsBase AS RB
UNION
SELECT	t.DataRunID,
        t.DataSetID,
		t.HasAllPayers,
        t.MeasureID,
        t.PayerID,
        t.PopulationID,
        t.ProductLineID,
        t.ReportType,
        t.ReportYear,
        t.ResultTypeID,
		0,
		0,
		0
FROM	ResultsBaseToFullMeasureList AS t
		LEFT OUTER JOIN ResultsBase AS RB
				ON RB.DataRunID = t.DataRunID AND
					RB.DataSetID = t.DataSetID AND
					RB.MeasureID = t.MeasureID AND
					RB.PayerID = t.PayerID AND
					RB.PopulationID = t.PopulationID AND
					RB.ProductLineID = t.ProductLineID
WHERE	RB.ResultTypeID IS NULL


GO
