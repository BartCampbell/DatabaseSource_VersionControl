SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetDescendantLoops]
(	
	@loopId Int,
	@includeSelf bit
)
RETURNS TABLE 
AS
RETURN 
(
  with children as (
    select @loopId as LoopId, l.*, -1 as Level
    from [dbo].Loop l
    where l.ParentLoopId = @loopId
  
    union all
  
    select c.LoopId, l.*, c.Level - 1 as Level
    from children c
    join [dbo].Loop l on c.Id = l.ParentLoopId
  )
  select Id, ParentLoopId, InterchangeId, TransactionSetId, SpecLoopId, LevelId, LevelCode, StartingSegmentId, EntityIdentifierCode, 0 as Level
  from [dbo].Loop 
  where Id = @loopId
  and @includeSelf = 1
  
  union
  
  select Id, ParentLoopId, InterchangeId, TransactionSetId, SpecLoopId, LevelId, LevelCode, StartingSegmentId, EntityIdentifierCode, Level
  from children
)
GO
