CREATE TABLE [dbo].[R_Client]
(
[CentauriClientID] [int] NOT NULL IDENTITY(112541, 1),
[ClientName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[ClientHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(concat(rtrim(ltrim(coalesce([CentauriClientID],''))),':',rtrim(ltrim(coalesce([ClientName],'')))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Client] ADD CONSTRAINT [PK_R_Client] PRIMARY KEY CLUSTERED  ([CentauriClientID]) ON [PRIMARY]
GO
