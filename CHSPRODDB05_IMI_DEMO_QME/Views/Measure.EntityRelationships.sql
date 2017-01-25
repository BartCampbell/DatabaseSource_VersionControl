SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


--Remember to apply related changes to Measure.ApplyEntityIterations.

CREATE VIEW [Measure].[EntityRelationships] AS
WITH DateComparerTypeE AS
(
	SELECT DateCompTypeID FROM Measure.DateComparerTypes WITH (NOLOCK) WHERE Abbrev = 'E'
),
DateComparerTypeV AS
(
	SELECT DateCompTypeID FROM Measure.DateComparerTypes WITH (NOLOCK) WHERE Abbrev = 'V'
),
IterationBase AS
(
	SELECT	MEC.EntityID, CAST(2 AS tinyint) AS Iteration, 
			ME.MeasureSetID, MEC.DateComparerLink AS ParentID
	FROM	Measure.Entities AS ME
			INNER JOIN Measure.EntityCriteria AS MEC WITH (NOLOCK)
					ON ME.EntityID = MEC.EntityID AND
						ME.IsEnabled = 1 AND
						MEC.IsEnabled = 1 
			INNER JOIN Measure.DateComparers AS MDC WITH (NOLOCK)
					ON MEC.DateComparerID = MDC.DateComparerID AND
						MDC.DateCompTypeID IN	(	
													SELECT DateCompTypeID FROM DateComparerTypeE
													UNION 
													SELECT DateCompTypeID FROM DateComparerTypeV
												)
	WHERE	MEC.DateComparerLink IS NOT NULL
	UNION 
	SELECT	MEC.EntityID, CAST(2 AS tinyint) AS Iteration, 
			ME.MeasureSetID, MEC.DateComparerInfo AS ParentID
	FROM	Measure.Entities AS ME
			INNER JOIN Measure.EntityCriteria AS MEC WITH (NOLOCK)
					ON ME.EntityID = MEC.EntityID AND
						ME.IsEnabled = 1 AND
						MEC.IsEnabled = 1 
			INNER JOIN Measure.DateComparers AS MDC WITH (NOLOCK)
					ON MEC.DateComparerID = MDC.DateComparerID AND
						MDC.DateCompTypeID IN	(
													SELECT DateCompTypeID FROM DateComparerTypeE
												)
			INNER JOIN Measure.Entities AS t WITH (NOLOCK)
					ON MEC.DateComparerInfo = t.EntityID AND
						t.IsEnabled = 1
),
Iterations AS
(
	SELECT	ME.EntityID, CAST(1 AS tinyint) AS Iteration, ME.MeasureSetID,
			CAST(NULL AS int) AS ParentID
	FROM	Measure.Entities AS ME WITH (NOLOCK)
	WHERE	(EntityID NOT IN (SELECT DISTINCT EntityID FROM IterationBase))
	UNION
	SELECT  EntityID, Iteration, MeasureSetID, ParentID
	FROM	IterationBase
	UNION ALL
	SELECT	t2.EntityID, CAST(t1.Iteration + 1 AS tinyint) AS Iteration,
			t2.MeasureSetID, t1.ParentID
	FROM	Iterations AS t1
			INNER JOIN IterationBase AS t2
					ON t1.EntityID = t2.ParentID AND
						t1.MeasureSetID = t2.MeasureSetID
	WHERE	t1.Iteration < 32 AND
			t1.ParentID IS NOT NULL
)
SELECT DISTINCT * FROM Iterations --ORDER BY MeasureSetID, EntityID, ParentID 

GO
