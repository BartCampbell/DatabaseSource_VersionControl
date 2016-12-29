CREATE TABLE [dbo].[tblHour]
(
[Hour_PK] [smallint] NOT NULL,
[Hour_Text] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblHour] ADD CONSTRAINT [PK_tblHour] PRIMARY KEY CLUSTERED  ([Hour_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
