CREATE TABLE [dbo].[H_User]
(
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[User_PK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientUserID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_User] ADD CONSTRAINT [PK_H_User] PRIMARY KEY CLUSTERED  ([H_User_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
