SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[vwSubscriberName]
AS
    SELECT
	    n.InterchangeID,
	    n.PositionInInterchange,
	    n.TransactionSetID,
	    n.LoopId,
	    n.ParentLoopId,
	    nx1.Definition AS Subscriber,
	    nx2.Definition AS SubscriberType,
	    CONVERT(VARCHAR(80),n.[03]) AS SubscriberLastName,
	    CONVERT(VARCHAR(80),n.[04]) AS SubscriberFirstName,
	    CONVERT(VARCHAR(80),n.[05]) AS SubscriberMiddleName,
	    CONVERT(VARCHAR(10),n.[06]) AS SubscriberNamePrefix,
	    CONVERT(VARCHAR(10),n.[07]) AS SubscriberNameSuffix,
	    nx8.Definition AS SubscriberIDType,
	    CONVERT(VARCHAR(80),n.[09]) AS SubscriberID,
	    nx10.Definition AS EntityRelationship
    FROM  NM1 AS n
		LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
								  AND nx1.ElementId = 98
		LEFT JOIN X12CodeList AS nx2 ON n.[02] = nx2.Code
								  AND nx2.ElementId = 1065
		LEFT JOIN X12CodeList AS nx8 ON n.[08] = nx8.Code
								  AND nx8.ElementId = 66
		LEFT JOIN X12CodeList AS nx10 ON n.[10] = nx10.Code
								  AND nx10.ElementId = 706;
GO
