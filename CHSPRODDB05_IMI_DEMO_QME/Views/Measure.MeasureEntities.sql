SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Measure].[MeasureEntities] AS
SELECT	t.EntityID,
        t.MeasureID, 
		MMS.MeasureSetID 
FROM	Measure.MeasureSets AS MMS
		CROSS APPLY Measure.GetMeasureEntities(DEFAULT, DEFAULT, MMS.MeasureSetID) AS t;

GO
