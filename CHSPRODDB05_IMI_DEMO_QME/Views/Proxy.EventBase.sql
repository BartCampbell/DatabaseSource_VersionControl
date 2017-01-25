SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[EventBase] AS
SELECT  [Allow],
        [BatchID],
        [BeginDate],
		[BitClaimAttribs],
		[BitClaimSrcTypes],
		[BitSpecialties],
        [ClaimTypeID],
        [Code],
        [CodeID],
        [CodeTypeID],
        [CountAllowed],
        [CountCriteria],
        [CountDenied],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [Days],
        [DSClaimCodeID],
        [DSClaimID],
        [DSClaimLineID],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [EventBaseID],
        [EventCritID],
        [EventID],
        [EventTypeID],
        [HasCodeReqs],
        [HasDateReqs],
        [HasEnrollReqs],
        [HasMemberReqs],
        [HasProviderReqs],
        [IsPaid],
		[IsSupplemental],
        [OptionNbr],
        [RankOrder],
        [RowID],
        [Value]
FROM    Internal.[EventBase]
WHERE	(SpId = @@SPID);
GO
