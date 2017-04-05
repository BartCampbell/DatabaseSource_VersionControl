SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[Enrollment] AS
SELECT  [BatchID],
        [BeginDate],
        [BitBenefits],
		[BitProductLines],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [DSMemberID],
        [EligibilityID],
        [EndDate],
        [EnrollGroupID],
        [EnrollItemID],
        [IsEmployee],
		[Priority]
FROM    Internal.[Enrollment]
WHERE	(SpId = @@SPID);
GO
