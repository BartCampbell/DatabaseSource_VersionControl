CREATE TABLE [dbo].[ClaimCodeTypes]
(
[CodeType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeID] [smallint] NOT NULL IDENTITY(1, 1),
[Description] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClaimCodeTypes] ADD CONSTRAINT [PK_ClaimCodeTypes] PRIMARY KEY CLUSTERED  ([CodeTypeID]) ON [PRIMARY]
GO
