SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwProviderInformation]
AS
    SELECT DISTINCT
	    i.SenderId,
	    i.ReceiverId,
	    i.Date AS FileCreateDate,
	    l.SpecLoopId,
	    RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS Filename,
	    nx1.Definition,
	    CONVERT(VARCHAR(80),n.[09]) AS ProviderID,
	    nx8.Definition AS ProviderIDType,
	    CONVERT(VARCHAR(60),n.[03]) AS ProviderLastName,
	    CONVERT(VARCHAR(35),n.[04]) AS ProviderFirstName,
	    CONVERT(VARCHAR(35),n.[05]) AS ProviderMiddleName,
	    CONVERT(VARCHAR(35),n.[06]) AS ProviderPrefix,
	    CONVERT(VARCHAR(35),n.[07]) AS ProviderSuffix	    
    FROM  dbo.NM1 AS n
		INNER JOIN dbo.Interchange i ON n.InterchangeId = i.Id
		INNER JOIN dbo.Loop l ON n.ParentLoopId = l.Id
		LEFT JOIN dbo.X12CodeList AS nx1 ON n.[01] = nx1.Code
								  AND nx1.ElementId = 98
		LEFT JOIN dbo.X12CodeList AS nx2 ON n.[02] = nx2.Code
								  AND nx2.ElementId = 1065
		LEFT JOIN dbo.X12CodeList AS nx8 ON n.[08] = nx8.Code
								  AND nx8.ElementId = 66
		LEFT JOIN dbo.X12CodeList AS nx10 ON n.[10] = nx10.Code
								  AND nx10.ElementId = 706
    WHERE nx1.Definition = 'Primary Care Provider' AND n.[03] <> ''

GO
