SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[RetrieveScoringSubMetrics] @MeasureID int
AS 
SELECT  M.MeasureID,
        H.HEDISSubMetricID,
        M.HEDISMeasure,
        H.HEDISSubMetricCode
FROM    dbo.Measure M
        JOIN dbo.HEDISSubMetric H ON M.MeasureID = H.MeasureID
WHERE   M.MeasureID = @MeasureID
ORDER BY M.HEDISMeasure,
        H.HEDISSubMetricCode



GO
