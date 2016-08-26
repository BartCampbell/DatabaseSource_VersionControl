CREATE TABLE [dbo].[tblUserSession]
(
[Session_PK] [bigint] NOT NULL IDENTITY(1, 1),
[User_PK] [smallint] NULL,
[SessionStart] [smalldatetime] NULL,
[SessionEnd] [smalldatetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserSession] ADD CONSTRAINT [PK_tblUserSession] PRIMARY KEY CLUSTERED  ([Session_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
