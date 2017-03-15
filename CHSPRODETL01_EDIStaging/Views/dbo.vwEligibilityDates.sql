SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwEligibilityDates]
AS
     SELECT
          InterChangeID,
          TransactionSetID,
          ParentLoopID,
          CONVERT(VARCHAR(35),[Medicaid Begin]) AS EffDate,
          CONVERT(VARCHAR(35),[Medicaid End]) AS TermDate
     FROM
     (
         SELECT
              d.InterchangeID,
              d.TransactionSetID,
              ISNULL(l.ParentLoopId, d.ParentLoopId) AS ParentLoopId,
              dx1.Definition AS DateType,
              d.[03] AS Dates
         FROM  dbo.DTP AS d
               INNER JOIN dbo.Loop AS l ON d.ParentLoopId = l.Id
               INNER JOIN X12CodeList AS dx1 ON d.[01] = dx1.Code
                                                AND dx1.ElementId = 374
         WHERE dx1.Definition IN('Medicaid Begin', 'Medicaid End')
               AND d.[03] <> ''
     ) AS src PIVOT(MIN(Dates) FOR DateType IN(
          [Medicaid Begin],
          [Medicaid End])) AS PivotTable;


GO
