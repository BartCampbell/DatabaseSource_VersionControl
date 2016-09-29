CREATE TABLE [dbo].[tblChannel]
(
[Channel_PK] [int] NOT NULL IDENTITY(1, 1),
[Channel_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblChannel] ADD CONSTRAINT [PK_tblChannel] PRIMARY KEY CLUSTERED  ([Channel_PK]) ON [PRIMARY]
GO
