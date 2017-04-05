SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[Events] AS
SELECT  [BatchID],
        [BeginDate],
        [BeginOrigDate],
        [ClaimTypeID],
        [CodeID],
        [CountClaims],
        [CountCodes],
        [CountLines],
        [CountProviders],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [Days],
        [DispenseID],
        [DSClaimID],
        [DSClaimLineID],
        [DSEventID],
        [DSMemberID],
        [DSProviderID],
        [EndDate],
        [EndOrigDate],
        [EventBaseID],
        [EventCritID],
        [EventID],
		[EventInfo],
		[EventMergeInfo],
		[EventXferInfo],
		[EventValueInfo],
		[IsPaid],
		[IsSupplemental],
        [IsXfer],
        [Value],
        [XferID]
FROM    Internal.[Events]
WHERE   (SpId = @@SPID) ;
GO
