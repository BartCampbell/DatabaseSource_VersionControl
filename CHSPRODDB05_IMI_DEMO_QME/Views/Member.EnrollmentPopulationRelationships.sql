SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Member].[EnrollmentPopulationRelationships] AS
WITH PopulationRelationships AS
(
	SELECT	MNP.PopulationID, MNP.ParentID, MNP.OwnerID
	FROM	Member.EnrollmentPopulations AS MNP
	WHERE	MNP.ParentID IS NOT NULL
	UNION ALL
	SELECT	t.PopulationID, MNP.ParentID, MNP.OwnerID
	FROM	PopulationRelationships AS t
			INNER JOIN Member.EnrollmentPopulations AS MNP
					ON MNP.PopulationID = t.ParentID AND
						MNP.OwnerID = t.OwnerID
	WHERE	MNP.ParentID IS NOT NULL
)
SELECT DISTINCT 
		* 
FROM	PopulationRelationships
GO
