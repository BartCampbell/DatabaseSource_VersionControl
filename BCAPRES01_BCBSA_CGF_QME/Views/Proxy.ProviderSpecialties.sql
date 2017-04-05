SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [Proxy].[ProviderSpecialties]
AS
SELECT  [BatchID],
        [DataRunID],
        [DataSetID],
        [DSProviderID],
        [SpecialtyID]
FROM    Internal.[ProviderSpecialties]
WHERE   (SpId = @@SPID) ;

GO
