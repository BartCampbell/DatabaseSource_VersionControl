CREATE TABLE [dbo].[tblSession]
(
[Session_PK] [tinyint] NOT NULL,
[Session_Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsActiveSession] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblSession] ADD CONSTRAINT [PK_tblSession] PRIMARY KEY CLUSTERED  ([Session_PK]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
