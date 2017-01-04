CREATE TABLE [ref].[CodeType]
(
[CodeTypeID] [int] NOT NULL IDENTITY(1, 1),
[CodeType] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CodeTypeDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[CodeType] ADD CONSTRAINT [PK_CodeType] PRIMARY KEY CLUSTERED  ([CodeTypeID]) ON [PRIMARY]
GO
