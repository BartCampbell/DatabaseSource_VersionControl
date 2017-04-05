SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 11/21/2013
-- Description:	Identifies the associations between events and their measures.
-- =============================================
CREATE FUNCTION [Measure].[GetMeasureEvents]
(
	@EventID int = NULL,
	@MeasureID int = NULL,
	@MeasureSetID int = NULL
)
RETURNS 
@Results TABLE 
(
	EventID int NOT NULL,
	MeasureID int NOT NULL,
	PRIMARY KEY (EventID, MeasureID)
)
AS
BEGIN
	DECLARE @Measure_MeasureEntities TABLE
	(
		EntityID int NOT NULL,
		MeasureID int NOT NULL,
		PRIMARY KEY (EntityID, MeasureID)
	);
	
	INSERT INTO @Measure_MeasureEntities 
	        (EntityID,
			MeasureID)
	SELECT	EntityID,
	        MeasureID 
	FROM	Measure.GetMeasureEntities(DEFAULT, @MeasureID, @MeasureSetID) AS MME
	WHERE	((@MeasureID IS NULL) OR (MME.MeasureID = @MeasureID)) AND
			((@MeasureSetID IS NULL) OR (MME.MeasureID IN (SELECT MeasureID FROM Measure.Measures WITH(NOLOCK) WHERE MeasureSetID = @MeasureSetID))) ;
	
	INSERT INTO @Results
			(EventID,
			MeasureID)
	--1) Normal Event Relationships...
	SELECT DISTINCT
			MEC.DateComparerInfo AS EventID, MME.MeasureID 
	FROM	@Measure_MeasureEntities AS MME --WITH (NOLOCK)
			INNER JOIN Measure.EntityCriteria AS MEC WITH (NOLOCK)
					ON MME.EntityID = MEC.EntityID AND
						MEC.IsEnabled = 1
			INNER JOIN Measure.DateComparers AS MDC WITH (NOLOCK)
					ON MEC.DateComparerID = MDC.DateComparerID
			INNER JOIN Measure.DateComparerTypes AS MDCT WITH (NOLOCK)
					ON MDC.DateCompTypeID = MDCT.DateCompTypeID
	WHERE	(MDCT.Abbrev = 'V') AND
			((@EventID IS NULL) OR (MEC.DateComparerInfo = @EventID))
	UNION
	--2) Transfers...
	SELECT DISTINCT
			MVT.ToEventID AS EventID, MME.MeasureID 
	FROM	@Measure_MeasureEntities AS MME-- WITH (NOLOCK)
			INNER JOIN Measure.EntityCriteria AS MEC WITH (NOLOCK)
					ON MME.EntityID = MEC.EntityID AND
						MEC.IsEnabled = 1
			INNER JOIN Measure.DateComparers AS MDC WITH (NOLOCK)
					ON MEC.DateComparerID = MDC.DateComparerID
			INNER JOIN Measure.DateComparerTypes AS MDCT WITH (NOLOCK)
					ON MDC.DateCompTypeID = MDCT.DateCompTypeID
			INNER JOIN Measure.EventTransfers AS MVT WITH (NOLOCK)
					ON MEC.DateComparerInfo = MVT.FromEventID
	WHERE	MDCT.Abbrev = 'V' AND
			((@EventID IS NULL) OR (MVT.ToEventID = @EventID))
	UNION
	--3) Claim Attributes...
	SELECT	MV.EventID, MME.MeasureID
	FROM	@Measure_MeasureEntities AS MME --WITH (NOLOCK)
			INNER JOIN Measure.Measures AS MM WITH (NOLOCK)
					ON MME.MeasureID = MM.MeasureID
			INNER JOIN Measure.[Events] AS MV WITH (NOLOCK)
					ON MM.MeasureSetID = MV.MeasureSetID AND
						MV.IsClaimAttrib = 1
	WHERE	((@EventID IS NULL) OR (MV.EventID = @EventID));
			
	RETURN;
END
GO
