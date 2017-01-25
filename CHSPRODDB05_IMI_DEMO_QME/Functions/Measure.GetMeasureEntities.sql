SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/21/2013
-- Description:	Identifies the associations between entities and their measures.
-- =============================================
CREATE FUNCTION [Measure].[GetMeasureEntities]
(
	@EntityID int = NULL,
	@MeasureID int = NULL,
	@MeasureSetID int = NULL
)
RETURNS 
@Results TABLE 
(
	EntityID int NOT NULL,
	MeasureID int NOT NULL,
	PRIMARY KEY (EntityID, MeasureID)
)
AS
BEGIN
	DECLARE @Measure_EntityRelationships TABLE
	(
		EntityID int NOT NULL,
		Iteration tinyint NOT NULL,
		MeasureSetID int NOT NULL,
		ParentID int NULL
	);
	
	INSERT INTO @Measure_EntityRelationships 
			(EntityID,
	        Iteration,
	        MeasureSetID,
	        ParentID)
	SELECT	EntityID,
	        Iteration,
	        MeasureSetID,
	        ParentID
	FROM	Measure.EntityRelationships AS MER
	WHERE	((@EntityID IS NULL) OR (MER.EntityID = @EntityID)) AND
			((@MeasureSetID IS NULL) OR (MER.MeasureSetID = @MeasureSetID));
	
	INSERT INTO @Results
			(EntityID,
			MeasureID)
	SELECT DISTINCT
			MER.EntityID, MeasureID
	FROM	@Measure_EntityRelationships AS MER --WITH (NOLOCK)
			INNER JOIN Measure.EntityToMetricMapping METMM WITH (NOLOCK)
					ON MER.EntityID = METMM.EntityID
			INNER JOIN Measure.Metrics AS MX WITH (NOLOCK)
					ON METMM.MetricID = MX.MetricID
	WHERE	((@EntityID IS NULL) OR (MER.EntityID = @EntityID))
	UNION
	SELECT DISTINCT
			MER.ParentID, MeasureID
	FROM	@Measure_EntityRelationships AS MER --WITH (NOLOCK)
			INNER JOIN Measure.EntityToMetricMapping METMM WITH (NOLOCK)
					ON MER.ParentID = METMM.EntityID
			INNER JOIN Measure.Metrics AS MX WITH (NOLOCK)
					ON METMM.MetricID = MX.MetricID 
	WHERE	(MER.ParentID IS NOT NULL) AND
			((@EntityID IS NULL) OR (MER.ParentID = @EntityID))
	UNION
	SELECT DISTINCT
			MER.ParentID, MeasureID
	FROM	@Measure_EntityRelationships AS MER --WITH (NOLOCK)
			INNER JOIN Measure.EntityToMetricMapping METMM WITH (NOLOCK)
					ON MER.EntityID = METMM.EntityID
			INNER JOIN Measure.Metrics AS MX WITH (NOLOCK)
					ON METMM.MetricID = MX.MetricID
	WHERE	(MER.ParentID IS NOT NULL) AND
			((@EntityID IS NULL) OR (MER.ParentID = @EntityID))
	UNION
	SELECT DISTINCT	
			MER.EntityID, MeasureID
	FROM	@Measure_EntityRelationships AS MER --WITH (NOLOCK)
			INNER JOIN Measure.EntityToMetricMapping METMM WITH (NOLOCK)
					ON MER.ParentID = METMM.EntityID
			/*****************************************************/
			--Added 12/4/2012 based on screen development
			INNER JOIN Measure.EntityToMetricMapping AS METMM2 WITH (NOLOCK)
					ON MER.EntityID = METMM2.EntityID 
			/*****************************************************/
			INNER JOIN Measure.Metrics AS MX WITH (NOLOCK)
					ON METMM.MetricID = MX.MetricID 
					/*****************************************************/
					--Added 12/4/2012 based on screen development
					AND METMM2.MetricID = MX.MetricID
					/*****************************************************/
	WHERE	((@EntityID IS NULL) OR (MER.EntityID = @EntityID));
			
	RETURN;
END

GO
