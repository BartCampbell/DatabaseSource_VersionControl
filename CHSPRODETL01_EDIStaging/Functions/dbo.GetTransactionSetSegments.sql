SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[GetTransactionSetSegments]
(	
	@transactionSetId Int, @includeControlSegments bit, @revisionId int
)
RETURNS TABLE 
AS
RETURN 
(
  with allSegments as (
    select *
    from [dbo].Segment
    where TransactionSetId = @TransactionSetId

    union

    select *
    from [dbo].Segment
    where FunctionalGroupId = (select top 1 FunctionalGroupId 
                                from [dbo].Segment 
                                where TransactionSetId = @transactionSetId)
    and segmentId in ('GS','GE')
    and @includeControlSegments = 1

    union

    select *
    from [dbo].Segment
    where InterchangeId = (select top 1 InterchangeId 
                                from [dbo].Segment 
                                where TransactionSetId = @transactionSetId)
    and segmentId in ('ISA','IEA')
    and @includeControlSegments = 1
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
