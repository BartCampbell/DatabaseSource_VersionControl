CREATE TABLE [dbo].[R_Network]
(
[CentauriNetworkID] [int] NOT NULL IDENTITY(1001000, 1),
[NPI] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientNetworkID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[NetworkHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriNetworkID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Network] ADD CONSTRAINT [PK_R_Network] PRIMARY KEY CLUSTERED  ([CentauriNetworkID]) ON [PRIMARY]
GO
