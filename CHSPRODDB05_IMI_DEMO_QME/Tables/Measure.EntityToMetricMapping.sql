CREATE TABLE [Measure].[EntityToMetricMapping]
(
[EntityID] [int] NOT NULL,
[MapTypeID] [tinyint] NOT NULL,
[MetricID] [int] NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Kriz, Mike
-- Create date: 8/8/2011
-- Description:	Inserts the product lines of the associated measure into Measure.EntityProductLines
-- =============================================
CREATE TRIGGER [Measure].[EntityToMetricMapping_DefaultProductLines_I]
   ON  [Measure].[EntityToMetricMapping]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	WITH 
	EntitiesWithoutProductLines AS
	(
		SELECT	EntityID
		FROM	Measure.Entities AS ME
		WHERE	(EntityID NOT IN (SELECT DISTINCT EntityID FROM Measure.EntityProductLines))
	),
	EntityProductLines AS
	(
		SELECT DISTINCT
				MEN.EntityID, MMPL.ProductLineID
		FROM	Measure.EntityEnrollment AS MEN
				INNER JOIN EntitiesWithoutProductLines AS t
						ON MEN.EntityID = t.EntityID
				INNER JOIN INSERTED /*Measure.EntityToMetricMapping*/ AS METMM
						ON MEN.EntityID = METMM.EntityID
				INNER JOIN Measure.Metrics AS MX
						ON METMM.MetricID = MX.MetricID
				INNER JOIN Measure.MeasureProductLines AS MMPL
						ON MX.MeasureID = MMPL.MeasureID
	)
    INSERT INTO Measure.EntityProductLines 
			(EntityID,
			ProductLineID)
	SELECT DISTINCT
			t.EntityID, t.ProductLineID
	FROM	EntityProductLines AS t
			LEFT OUTER JOIN Measure.EntityProductLines AS MEPL
					ON t.EntityID = MEPL.EntityID AND
						t.ProductLineID = MEPL.ProductLineID
	WHERE	(MEPL.ProductLineID IS NULL);

END



GO
ALTER TABLE [Measure].[EntityToMetricMapping] ADD CONSTRAINT [PK_MetricEntityMapping] PRIMARY KEY CLUSTERED  ([EntityID], [MapTypeID], [MetricID]) ON [PRIMARY]
GO
