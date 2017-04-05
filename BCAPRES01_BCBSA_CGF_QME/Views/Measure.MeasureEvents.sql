SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Measure].[MeasureEvents] AS
SELECT	t.EventID,
        t.MeasureID,
		MMS.MeasureSetID
FROM	Measure.MeasureSets AS MMS
		CROSS APPLY Measure.GetMeasureEvents(DEFAULT, DEFAULT, MMS.MeasureSetID) AS t;
GO
