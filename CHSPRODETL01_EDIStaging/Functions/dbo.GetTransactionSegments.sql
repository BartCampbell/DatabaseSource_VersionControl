SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetTransactionSegments]
(	
	@loopId Int, @includeControlSegments bit, @revisionId int
)
RETURNS TABLE 
AS
RETURN 
(
  with transactionLoops as ( 
    select * from [dbo].GetAncestorLoops(@loopId, 1)
    union all
    select * from [dbo].GetDescendantLoops(@loopId, 0)
  )
  , ancestorsOtherChildLoops as (
    select distinct l.*
    from transactionLoops tl
    join [dbo].Loop l on l.ParentLoopId = tl.Id and tl.StartingSegmentId <> 'HL'
    where tl.[Level] > 1 or (tl.Level = 1 and l.SpecLoopId <> (select SpecLoopId from [dbo].[Loop] where Id = @loopId))

    union all

    select l.*
    from ancestorsOtherChildLoops poc
    join [dbo].Loop l on poc.Id = l.ParentLoopId
    where l.SpecLoopId <> (select SpecLoopId from [dbo].[Loop] where Id = @loopId)
)
, transactionChildLoops as (  
    
    select distinct l.*
    from [dbo].Loop l
    where ParentLoopId is null
    and TransactionSetId = (select top 1 TransactionSetID from transactionLoops)
    and l.SpecLoopId <> (select SpecLoopId from [dbo].[Loop] where Id = @loopId)
    and l.StartingSegmentId <> 'HL'
  )
  , transactionSegments as (
    select *
    from [dbo].Segment
    where LoopId in (select Id from transactionLoops)
    or (LoopId is null and ParentLoopId in (select Id from transactionLoops))
    or LoopId in (select Id from ancestorsOtherChildLoops)
    or (LoopId is null and ParentLoopId in (select Id from ancestorsOtherChildLoops))
    or LoopId in (select Id from transactionChildLoops)
    or (LoopId is null and ParentLoopId in (select Id from transactionChildLoops))    
    or (TransactionSetId = (select top 1 TransactionSetId from transactionLoops) 
      and (SegmentId in ('ST','SE') or ParentLoopId is null and LoopId is null))
  )
  , allSegments as (
    select * 
    from transactionSegments

    union all

    select *
    from [dbo].Segment
    where FunctionalGroupId = (select top 1 FunctionalGroupId from transactionSegments)
    and SegmentId in ('GS','GE') and @includeControlSegments = 1

    union all

    select *
    from [dbo].Segment
    where InterchangeId = (select top 1 InterchangeId from transactionSegments)
    and SegmentId in ('ISA','IEA') and @includeControlSegments = 1
  )
  , revisedSegments as (
  select *, RowNum = ROW_NUMBER() OVER (PARTITION BY InterchangeId, PositionInInterchange ORDER BY RevisionId desc)
  from allSegments
  where RevisionId <= @revisionId
  )
  select *
  from revisedSegments
  where RowNum = 1 and Deleted = 0
)
GO
