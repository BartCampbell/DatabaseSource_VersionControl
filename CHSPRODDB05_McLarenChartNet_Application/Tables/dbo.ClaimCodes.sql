CREATE TABLE [dbo].[ClaimCodes]
(
[CodeType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeID] [smallint] NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeID] [int] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimCodes] ADD CONSTRAINT [PK_ClaimCodes] PRIMARY KEY CLUSTERED  ([CodeID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ClaimCodes_CodeTypeID] ON [dbo].[ClaimCodes] ([CodeTypeID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimCodes] ADD CONSTRAINT [FK_ClaimCodes_ClaimCodeTypes] FOREIGN KEY ([CodeTypeID]) REFERENCES [dbo].[ClaimCodeTypes] ([CodeTypeID])
GO
