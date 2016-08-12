CREATE TABLE [dbo].[tblUserPasswordLog]
(
[User_PK] [smallint] NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dtPassword] [date] NULL
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [IX_tblUserPasswordLog] ON [dbo].[tblUserPasswordLog] ([User_PK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
