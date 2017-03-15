CREATE TABLE [dbo].[TransactionSet]
(
[Id] [int] NOT NULL,
[InterchangeId] [int] NOT NULL,
[FunctionalGroupId] [int] NOT NULL,
[IdentifierCode] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ControlNumber] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ImplementationConventionRef] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TransactionSet] ADD CONSTRAINT [PK_Transaction_dbo] PRIMARY KEY CLUSTERED  ([Id]) ON [PRIMARY]
GO
