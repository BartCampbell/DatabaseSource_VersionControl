SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[vwInsurerSponsor]
AS
     SELECT
          N.InterchangeId,
          N.PositionInInterchange,
          N.TransactionSetId,
          l.SpecLoopID,
          N.LoopId,
          CONVERT(VARCHAR(3),N.[01]) [01],
          nx1.Definition,
          CONVERT(VARCHAR(60),N.[02]) [02],
          CONVERT(VARCHAR(2),N.[03]) [03],
          CONVERT(VARCHAR(80),N.[04]) [04],
          CONVERT(VARCHAR(2),N.[05]) [05],
          CONVERT(VARCHAR(3),N.[06]) [06]
     FROM N1 AS n
          INNER JOIN Loop AS l ON n.LoopId = l.Id
          LEFT JOIN X12CodeList AS nx1 ON n.[01] = nx1.Code
                                          AND nx1.ElementId = 98;

GO
