CREATE TABLE [dbo].[R_AdvanceContactNote]
(
[CentauriContactNoteID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactNoteID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNoteHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriContactNoteID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceContactNote] ADD CONSTRAINT [PK_CentauriContactNoteID] PRIMARY KEY CLUSTERED  ([CentauriContactNoteID]) ON [PRIMARY]
GO
