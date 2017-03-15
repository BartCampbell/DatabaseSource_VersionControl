SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dv].[vw834CommNumbers]
AS
     SELECT  
	    RIGHT(i.Filename, CHARINDEX('\', REVERSE(i.Filename)) - 1) AS RecordSource,
	    UPPER(CONVERT( CHAR(32), HASHBYTES('MD5', UPPER(CONCAT(RTRIM(LTRIM(COALESCE(x3.Definition, ''))), ':', RTRIM(LTRIM(COALESCE(CONVERT(VARCHAR(256),p.[04]), ''))), ':', RTRIM(LTRIM(COALESCE(x5.Definition, ''))), ':', RTRIM(LTRIM(COALESCE(CONVERT(VARCHAR(256),p.[06]), ''))), ':', RTRIM(LTRIM(COALESCE(x7.Definition, ''))), ':', RTRIM(LTRIM(COALESCE(CONVERT(VARCHAR(256),p.[08]), '')))))), 2)) AS H_Contact_RK,
	    CONCAT(x3.Definition, CONVERT(VARCHAR(256),p.[04]), x5.Definition, CONVERT(VARCHAR(256),p.[06]), x7.Definition, CONVERT(VARCHAR(256),p.[08])) AS Contact_BK,
	    p.InterchangeId,
	    p.TransactionSetId,
	    ISNULL(l.parentloopid,p.ParentLoopId) AS ParentLoopID,
	    l.SpecLoopId,
	    x1.Definition AS MemberContact,
	    x3.Definition AS ContactType1,
	    CONVERT(VARCHAR(256),p.[04]) AS Contact1,
	    x5.Definition AS ContactType2,
	    CONVERT(VARCHAR(256),p.[06]) AS Contact2,
	    x7.Definition AS ContactType3,
	    CONVERT(VARCHAR(256),p.[08]) AS Contact3
    FROM dbo.PER p 
	    INNER JOIN dbo.Interchange i ON p.InterchangeId = i.Id 
	    LEFT JOIN dbo.Loop l ON p.ParentLoopId = l.Id
	    LEFT JOIN dbo.X12CodeList x1 ON p.[01] = x1.Code AND x1.ElementId = 366
	    LEFT JOIN dbo.X12CodeList x3 ON p.[03] = x3.Code AND x3.ElementId = 365
	    LEFT JOIN dbo.X12CodeList x5 ON p.[05] = x5.Code AND x5.ElementId = 365
	    LEFT JOIN dbo.X12CodeList x7 ON p.[07] = x7.Code AND x7.ElementId = 365


GO
