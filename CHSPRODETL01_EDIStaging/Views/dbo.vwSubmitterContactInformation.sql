SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







CREATE VIEW [dbo].[vwSubmitterContactInformation]
AS
SELECT
     i.Id AS InterchangeID,
	ts.Id AS TransactionSetID,
     px1.Definition AS ContactCode,
     CONVERT(VARCHAR(80),p.[02]) AS ContactName,
     px3.Definition AS CommType1,
     CONVERT(VARCHAR(256),p.[04]) AS CommNumber1,
     px5.Definition AS CommType2,
	CONVERT(VARCHAR(256),p.[06]) AS CommNumber2,
	px7.Definition AS CommType3,
	CONVERT(VARCHAR(256),p.[08]) AS CommNumber3
FROM  Interchange AS i
      INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
      INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                         AND ts.InterchangeId = i.Id
      INNER JOIN LastRevPER AS p ON p.InterchangeId = i.Id AND p.TransactionSetId = ts.Id
      LEFT JOIN X12CodeList AS px1 ON p.[01] = px1.Code
                                      AND px1.ElementId = 366
      LEFT JOIN X12CodeList AS px3 ON p.[03] = px3.Code
                                      AND px3.ElementId = 365
      LEFT JOIN X12CodeList AS px5 ON p.[05] = px5.Code
                                      AND px5.ElementId = 365
      LEFT JOIN X12CodeList AS px7 ON p.[07] = px7.Code 
							   AND px7.ElementId = 365




GO
