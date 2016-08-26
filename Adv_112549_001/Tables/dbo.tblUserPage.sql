CREATE TABLE [dbo].[tblUserPage]
(
[User_PK] [smallint] NOT NULL,
[Page_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserPage] ADD CONSTRAINT [PK_tblUserPage] PRIMARY KEY CLUSTERED  ([User_PK], [Page_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
