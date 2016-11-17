CREATE TABLE [dbo].[R_Session]
(
[CentauriSessionID] [int] NOT NULL IDENTITY(10000, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientSessionID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [date] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SessionHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriSessionID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_Session] ADD CONSTRAINT [PK_R_Session] PRIMARY KEY CLUSTERED  ([CentauriSessionID]) ON [PRIMARY]
GO
