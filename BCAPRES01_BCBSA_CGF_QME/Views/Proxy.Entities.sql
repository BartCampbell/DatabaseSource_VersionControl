SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[Entities] AS
SELECT  [BatchID],
        [BeginDate],
        [BeginOrigDate],
		[BitProductLines],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [Days],
        [DSEntityID],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [EndOrigDate],
        [EnrollGroupID],
        [EntityBaseID],
        [EntityCritID],
        [EntityID],
		[EntityInfo],
		[IsSupplemental],
        [Iteration],
        [LastSegBeginDate],
        [LastSegEndDate],
        [Qty],
        [SourceID],
        [SourceLinkID]
FROM    Internal.[Entities]
WHERE   (SpId = @@SPID) ;
GO
