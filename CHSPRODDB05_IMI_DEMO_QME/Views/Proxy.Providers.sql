SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[Providers]
AS
SELECT  [BatchID],
		[BitSpecialties],
        [DataRunID],
        [DataSetID],
		[DataSourceID],
        [DSProviderID],
        [IhdsProviderID],
        [ProviderID]
FROM    Internal.[Providers]
WHERE   (SpId = @@SPID) ;
GO
