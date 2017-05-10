CREATE TABLE [BCBSA_GDIT2017].[Users]
(
[UserID] [int] NOT NULL IDENTITY(1, 1),
[AssociationEmployeeFlag] [bit] NULL,
[FirstName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Email] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Phone] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [BCBSA_GDIT2017].[Users] ADD CONSTRAINT [pkUserID] PRIMARY KEY CLUSTERED  ([UserID]) ON [PRIMARY]
GO
