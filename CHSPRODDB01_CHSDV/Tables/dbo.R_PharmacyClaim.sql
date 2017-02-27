CREATE TABLE [dbo].[R_PharmacyClaim]
(
[CentauriPharmacyClaimID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientPharmacyClaimID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GNPharmacyClaimHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriPharmacyClaimID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_PharmacyClaim] ADD CONSTRAINT [PK_CentauriGNClaimID] PRIMARY KEY CLUSTERED  ([CentauriPharmacyClaimID]) ON [PRIMARY]
GO
