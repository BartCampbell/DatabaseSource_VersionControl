SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[vwClaimSegments]
AS
SELECT
     i.Id AS InterchangeId,
     i.SenderId,
     i.ReceiverId,
     i.ControlNumber AS I_ControlNumber,
     i.[Date],
     i.SegmentTerminator,
     i.ElementSeparator,
     i.ComponentSeparator,
     i.Filename,
     i.HasError,
     i.CreatedBy,
     i.CreatedDate,
     fg.Id AS FunctionalGroupId,
     fg.FunctionalIdCode,
     fg.ControlNumber AS FG_ControlNumber,
     fg.Version,
     ts.Id AS TransactionSetId,
     ts.IdentifierCode,
     ts.ControlNumber,
     ts.ImplementationConventionRef,
     l.Id AS LoopId,
     l.ParentLoopId,
     l.TransactionSetCode,
     l.SpecLoopId,
     l.LevelId,
     l.LevelCode,
     l.StartingSegmentId,
     l.EntityIdentifierCode,
     s.PositionInInterchange,
     s.RevisionId,
     s.Deleted,
     s.SegmentId,
     CONVERT(VARCHAR(MAX),s.Segment) AS Segment,
     r.Id,
     r.SchemaName,
     r.Comments,
     r.RevisionDate,
     r.RevisedBy
FROM Interchange AS i
     INNER JOIN FunctionalGroup AS fg ON i.id = fg.InterchangeId
     INNER JOIN TransactionSet AS ts ON ts.FunctionalGroupId = fg.Id
                                        AND ts.InterchangeId = i.Id
     INNER JOIN LOOP AS l ON l.TransactionSetId = ts.Id
                             AND l.InterchangeId = i.Id
     INNER JOIN Segment AS s ON i.Id = s.InterchangeId
                                AND s.LoopId = l.id
     INNER JOIN Revision AS r ON r.Id = s.RevisionId;




GO
