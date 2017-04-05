SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Proxy].[EnrollmentBenefits] AS
SELECT  [BatchID],
        [BenefitID],
        [DataRunID],
        [DataSetID],
        [EnrollItemID]
FROM    Internal.[EnrollmentBenefits]
WHERE	(SpId = @@SPID);


GO
