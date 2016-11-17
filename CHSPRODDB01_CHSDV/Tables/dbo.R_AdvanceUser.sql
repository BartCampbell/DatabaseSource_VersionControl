CREATE TABLE [dbo].[R_AdvanceUser]
(
[CentauriUserID] [int] NOT NULL IDENTITY(10001, 1),
[ClientID] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientUserID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserHashKey] AS (upper(CONVERT([char](32),hashbytes('MD5',upper(rtrim(ltrim(coalesce([CentauriUserID],''))))),(2))))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[R_AdvanceUser] ADD CONSTRAINT [PK_CentauriUserID] PRIMARY KEY CLUSTERED  ([CentauriUserID]) ON [PRIMARY]
GO
