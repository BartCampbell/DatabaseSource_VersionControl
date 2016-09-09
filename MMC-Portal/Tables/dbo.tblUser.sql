CREATE TABLE [dbo].[tblUser]
(
[User_PK] [int] NOT NULL IDENTITY(1, 1),
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Password] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email_Address] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsAdmin] [bit] NULL,
[IsCoder] [bit] NULL,
[IsClientStaff] [bit] NULL,
[IsClient] [bit] NULL,
[IsActive] [bit] NULL,
[isCoderSupervisor] [bit] NULL,
[h_id] [smallint] NULL,
[IsManager] [bit] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblUser] ADD CONSTRAINT [PK_tblUser] PRIMARY KEY CLUSTERED  ([User_PK]) ON [PRIMARY]
GO
