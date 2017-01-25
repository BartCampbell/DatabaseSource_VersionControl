SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Proxy].[Members] AS
SELECT  [BatchID],
		[CustomerMemberID],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [DOB],
        [DSMemberID],
        [Gender],
        [IhdsMemberID],
        [MemberID],
		[NameFirst],
		[NameLast]
FROM    Internal.[Members]
WHERE   (SpId = @@SPID) ;

GO
