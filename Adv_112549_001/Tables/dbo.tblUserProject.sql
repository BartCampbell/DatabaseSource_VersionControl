CREATE TABLE [dbo].[tblUserProject]
(
[User_PK] [smallint] NOT NULL,
[Project_PK] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserProject] ADD CONSTRAINT [PK_tblUserProject] PRIMARY KEY CLUSTERED  ([User_PK], [Project_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
