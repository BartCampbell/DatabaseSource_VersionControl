SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Cloud].[FileObjectHierarchy] AS 
WITH Relationships AS
(
	/*Identify Object Relationships through their Fields*/
	SELECT	NFR.ChildFieldID,
			NFF.FileObjectID AS ChildObjectID,
			NFR.ParentFieldID,
			PFF.FileObjectID AS ParentObjectID,
			1 AS Tier
	FROM	Cloud.FileFields AS NFF
			INNER JOIN Cloud.FileRelationships AS NFR
					ON NFF.FileFieldID = NFR.ChildFieldID 
			INNER JOIN Cloud.FileFields AS PFF
					ON  NFR.ParentFieldID = PFF.FileFieldID
),
ObjectRelationships AS
(
	/*Verify Objects are from the same File Format*/
	SELECT DISTINCT
			R.ChildObjectID, 
			CO.ObjectName AS ChildObjectName, 
			R.ParentObjectID,
			PO.ObjectName AS ParentObjectName
	FROM	Relationships AS R
			INNER JOIN Cloud.FileObjects AS CO
					ON R.ChildObjectID = CO.FileObjectID
			INNER JOIN Cloud.FileObjects AS PO
					ON R.ParentObjectID = PO.FileObjectID AND
						PO.FileFormatID = CO.FileFormatID 
),
TierRelationships AS 
(
	/*Identify Objects Hierarchy*/
	/*	Tier 1: Objects without any parents, but with children*/
	SELECT DISTINCT
			R1.ParentObjectID AS FileObjectID,
			CAST(NULL AS int) AS ParentID,
			1 AS Tier,
			CAST('/' + R1.ParentObjectName AS nvarchar(MAX)) AS XmlPath
	FROM	ObjectRelationships AS R1
			LEFT OUTER JOIN ObjectRelationships AS R2
					ON R1.ParentObjectID = R2.ChildObjectID  
	WHERE	(R2.ChildObjectID IS NULL)
	UNION
	/*	Tier 1: Objects without any relationships of any kind*/
	SELECT DISTINCT
			FileObjectID,
			CAST(NULL AS int) AS ParentID,
			1 AS Tier,
			CAST('/' + NFO.ObjectName AS nvarchar(MAX)) AS XmlPath
	FROM	Cloud.FileObjects AS NFO
			LEFT OUTER JOIN ObjectRelationships AS CO
					ON NFO.FileObjectID = CO.ChildObjectID 
			LEFT OUTER JOIN ObjectRelationships AS PO
					ON NFO.FileObjectID = PO.ParentObjectID 
	WHERE	(CO.ChildObjectID IS NULL) AND
			(PO.ParentObjectID IS NULL)
	UNION
	/*	Tier 2: Objects without any grandparents*/
	SELECT DISTINCT
			R1.ChildObjectID AS FileObjectID,
			r1.ParentObjectID AS ParentID,
			2 AS Tier,
			CAST('/' + R1.ParentObjectName + '/' + R1.ChildObjectName AS nvarchar(MAX)) AS XmlPath
	FROM	ObjectRelationships AS R1
			LEFT OUTER JOIN ObjectRelationships AS R2
					ON R1.ParentObjectID = R2.ChildObjectID  
	WHERE	(R2.ChildObjectID IS NULL)
	UNION ALL
	/*	Tier 3+: Loop through remaining objects*/
	SELECT	R2.ChildObjectID AS FileObjectID,
			R1.FileObjectID AS ParentID,
			R1.Tier + 1 AS Tier,
			CAST(R1.XmlPath + '/' + R2.ChildObjectName AS nvarchar(MAX)) AS XmlPath
	FROM	TierRelationships AS R1
			INNER JOIN ObjectRelationships R2
					ON R1.FileObjectID = R2.ParentObjectID AND
						R1.Tier >= 2
)
SELECT	TR.*
FROM	TierRelationships AS TR

GO
