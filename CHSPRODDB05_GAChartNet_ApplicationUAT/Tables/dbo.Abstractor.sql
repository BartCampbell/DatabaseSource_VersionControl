CREATE TABLE [dbo].[Abstractor]
(
[AbstractorID] [int] NOT NULL IDENTITY(1, 1),
[AbstractorName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AbstractorGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[UserName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Abstractor] ADD CONSTRAINT [PK_Abstractor] PRIMARY KEY CLUSTERED  ([AbstractorID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Abstractor_AbstractorName] ON [dbo].[Abstractor] ([AbstractorName]) ON [PRIMARY]
GO
