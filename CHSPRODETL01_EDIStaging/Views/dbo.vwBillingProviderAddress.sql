SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwBillingProviderAddress]
AS
     SELECT
          n3.InterchangeId,
          n3.PositionInInterchange,
          n3.TransactionSetId,
          n3.ParentLoopId,
          n3.LoopId,
          CONVERT(VARCHAR(100),n3.[01]) AS Addr1,
          CONVERT(VARCHAR(100),n3.[02]) AS Addr2,
          CONVERT(VARCHAR(100),n4.[01]) AS City,
          CONVERT(VARCHAR(50),n4.[02]) AS State,
          CONVERT(VARCHAR(20),n4.[02]) AS Zip,
          CONVERT(VARCHAR(20),n4.[04]) AS Country,
          CONVERT(VARCHAR(20),n4.[07]) AS CountrySub
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevN3 AS n3 ON i.id = n3.InterchangeId
                                        AND ts.id = n3.TransactionSetId
                                        AND l.id = n3.parentloopid
          INNER JOIN LastRevN4 AS n4 ON i.id = n4.InterchangeId
                                        AND ts.id = n4.TransactionSetId
                                        AND l.id = n4.parentloopid;


GO
