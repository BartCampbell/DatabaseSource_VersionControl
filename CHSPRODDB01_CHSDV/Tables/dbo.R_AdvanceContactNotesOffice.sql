CREATE TABLE [dbo].[R_AdvanceContactNotesOffice]
(
[CentauriContactNotesOfficeID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientContactNotesOfficeID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactNotesOfficeHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriContactNotesOfficeID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceContactNotesOffice] ADD CONSTRAINT [PK_CentauriContactNotesOfficeID] PRIMARY KEY CLUSTERED  ([CentauriContactNotesOfficeID]) ON [PRIMARY]
GO
