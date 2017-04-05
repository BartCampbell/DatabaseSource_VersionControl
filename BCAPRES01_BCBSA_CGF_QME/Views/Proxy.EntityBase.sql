SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [Proxy].[EntityBase] AS
SELECT  [Allow],
        [BatchID],
        [BeginDate],
        [BeginOrigDate],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [DateComparerID],
        [DateComparerInfo],
        [DateComparerLink],
        [Days],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [EndOrigDate],
        [EntityBaseID],
        [EntityBeginDate],
        [EntityCritID],
        [EntityEndDate],
		[EntityEnrollInfo],
        [EntityID],
		[EntityInfo],
		[EntityLinkInfo],
		[EntityQtyInfo],
        [IsForIndex],
		[IsSupplemental],
        [OptionNbr],
        [Qty],
        [QtyMax],
        [QtyMin],
		[QtyNoSupplemental],
        [RankOrder],
        [RowID],
        [SourceID],
        [SourceLinkID]
FROM    Internal.[EntityBase]
WHERE   (SpId = @@SPID);
GO
