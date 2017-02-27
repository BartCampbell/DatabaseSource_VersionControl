CREATE TABLE [dbo].[R_Pharmacy]
(
[CentauriPharmacyID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientPharmacyID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PharmacyHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriPharmacyID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Pharmacy] ADD CONSTRAINT [PK_CentauriPharmcyID] PRIMARY KEY CLUSTERED  ([CentauriPharmacyID]) ON [PRIMARY]
GO
