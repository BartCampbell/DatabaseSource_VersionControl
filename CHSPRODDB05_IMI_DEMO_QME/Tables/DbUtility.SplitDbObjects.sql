CREATE TABLE [DbUtility].[SplitDbObjects]
(
[AllowDestination] [bit] NOT NULL CONSTRAINT [DF_SplitDbObjects_AllowDest] DEFAULT ((0)),
[AllowSource] [bit] NOT NULL CONSTRAINT [DF_SplitDbObjects_AllowSource] DEFAULT ((1)),
[AllowSynonym] [bit] NOT NULL CONSTRAINT [DF_SplitDbObjects_AllowSynonym] DEFAULT ((0)),
[DmSplitConfigID] [smallint] NOT NULL,
[DmSplitDbObjectID] [int] NOT NULL IDENTITY(1, 1),
[IsActive] [bit] NOT NULL CONSTRAINT [DF_SplitDbObjects_IsActive] DEFAULT ((1)),
[ObjectName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [DbUtility].[SplitDbObjects] ADD CONSTRAINT [CK_SplitDbObjects_MustHaveDestOrSrc] CHECK (([AllowDestination]=(1) OR [AllowSource]=(1)))
GO
ALTER TABLE [DbUtility].[SplitDbObjects] ADD CONSTRAINT [CK_SplitDbObjects_SynonymIfEitherNoDestOrNoSrc] CHECK (([AllowSynonym]=(1) AND [AllowDestination]=(0) OR [AllowSource]=(0) OR [AllowSynonym]=(0)))
GO
ALTER TABLE [DbUtility].[SplitDbObjects] ADD CONSTRAINT [PK_SplitDbObjects] PRIMARY KEY CLUSTERED  ([DmSplitDbObjectID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SplitDbObjects] ON [DbUtility].[SplitDbObjects] ([DmSplitConfigID], [ObjectSchema], [ObjectName]) ON [PRIMARY]
GO
EXEC sp_addextendedproperty N'MS_Description', N'An object must be in either the destination or source or both.  ', 'SCHEMA', N'DbUtility', 'TABLE', N'SplitDbObjects', 'CONSTRAINT', N'CK_SplitDbObjects_MustHaveDestOrSrc'
GO
EXEC sp_addextendedproperty N'MS_Description', N'An object can only be marked for a synonym if it is in either in the destination or source, but not both.', 'SCHEMA', N'DbUtility', 'TABLE', N'SplitDbObjects', 'CONSTRAINT', N'CK_SplitDbObjects_SynonymIfEitherNoDestOrNoSrc'
GO
