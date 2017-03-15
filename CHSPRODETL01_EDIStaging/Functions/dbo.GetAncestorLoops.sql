SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetAncestorLoops]
(	
	@loopId Int,
	@includeSelf bit
)
RETURNS TABLE 
AS
RETURN 
(
    with parents as (
      select @loopId as [LoopId], l.*, 0 as [Level]
      from [dbo].[Loop] l
      where l.Id = @loopId

      union all

      select p.[LoopId], l.*, p.Level + 1 as [Level]
      from parents p
      join [dbo].[Loop] l on p.ParentLoopId = l.Id
    )
    select Id, ParentLoopId, InterchangeId, TransactionSetId, SpecLoopId, LevelId, LevelCode, StartingSegmentId, EntityIdentifierCode, [Level]
    from parents
    where @includeSelf = 1 or Level > 0
)
GO
