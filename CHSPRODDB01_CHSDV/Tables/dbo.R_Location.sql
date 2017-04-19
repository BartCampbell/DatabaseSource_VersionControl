CREATE TABLE [dbo].[R_Location]
(
[CentauriLocationID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZIP] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriLocationID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Location] ADD CONSTRAINT [PK_CentauriLocationID1] PRIMARY KEY CLUSTERED  ([CentauriLocationID]) ON [PRIMARY]
GO
