CREATE TABLE [dbo].[tblUserChannel]
(
[User_PK] [smallint] NOT NULL,
[Channel_PK] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUserChannel] ADD CONSTRAINT [PK_tblUserChannel] PRIMARY KEY CLUSTERED  ([User_PK], [Channel_PK]) ON [PRIMARY]
GO
