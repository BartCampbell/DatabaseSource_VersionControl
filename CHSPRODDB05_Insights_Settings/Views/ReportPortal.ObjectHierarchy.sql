SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [ReportPortal].[ObjectHierarchy]
AS
WITH RootResults AS 
(
	SELECT	RO.RptObjID AS ChildID,
            CONVERT(smallint, NULL) AS RptObjID,
            CONVERT(int, 0) AS Tier
    FROM	ReportPortal.[Objects] AS RO WITH (NOLOCK)
            LEFT OUTER JOIN ReportPortal.Navigation AS RN WITH (NOLOCK) 
					ON RN.ChildID = RO.RptObjID
    WHERE	(RN.RptNavID IS NULL)
),
Results AS 

(
	--Root
	SELECT	ChildID,
			RptObjID,
			Tier
	FROM	RootResults
              UNION ALL
	--Root's Ancestors
	SELECT	RN.ChildID,
			RN.RptObjID,
			t.Tier + 1 AS Tier
	FROM	Results t --Recursive CTE
			INNER JOIN ReportPortal.Navigation AS RN WITH (NOLOCK) 
					ON RN.RptObjID = t.ChildID
	WHERE	(t.Tier <= 32)
)
SELECT TOP 100 PERCENT
		t.ChildID,
		t.RptObjID,
		t.Tier
FROM	Results AS t
ORDER BY t.Tier,
        t.ChildID;
GO
