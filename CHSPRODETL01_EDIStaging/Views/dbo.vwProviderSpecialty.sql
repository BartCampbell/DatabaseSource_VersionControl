SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwProviderSpecialty]
AS
     SELECT
          p.InterchangeId,
          p.PositionInInterchange,
          p.TransactionSetId,
          p.ParentLoopId,
          p.LoopId,
          px1.Definition AS ProviderType,
          px2.Definition AS TaxonomySource,
          CONVERT(VARCHAR(80),p.[03]) AS ProviderTaxonomy,
          x.TaxonomyDesc
     FROM Interchange AS i
          INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
          INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                             AND ts.InterchangeId = i.Id
          INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                                  AND l.InterchangeId = i.Id
          INNER JOIN LastRevPRV AS p ON i.id = p.InterchangeId
                                        AND ts.id = p.TransactionSetId
                                        AND l.id = p.parentloopid
          LEFT JOIN X12CodeList AS px1 ON p.[01] = px1.Code
                                          AND px1.ElementId = 1221
          LEFT JOIN X12CodeList AS px2 ON p.[02] = px2.Code
                                          AND px2.ElementId = 128
          LEFT JOIN vwTaxonomySpecialtyXref AS x ON p.[03] = x.TaxonomyCode;


GO
