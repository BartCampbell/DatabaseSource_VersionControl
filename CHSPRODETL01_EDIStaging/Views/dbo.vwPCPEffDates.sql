SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwPCPEffDates]
AS
     SELECT
          d.InterchangeID,
          d.TransactionSetID,
          ISNULL(l.ParentLoopId, d.ParentLoopId) AS ParentLoopId,
          CONVERT(VARCHAR(35),d.[03]) AS PCPEffDate
     FROM  dbo.DTP AS d
           INNER JOIN dbo.Loop AS l ON d.ParentLoopId = l.Id
           INNER JOIN X12CodeList AS dx1 ON d.[01] = dx1.Code
                                            AND dx1.ElementId = 374
     WHERE dx1.Definition = 'Benefit Begin'
           AND d.[03] <> '';


GO
