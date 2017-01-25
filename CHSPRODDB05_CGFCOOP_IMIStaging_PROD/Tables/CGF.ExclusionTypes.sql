CREATE TABLE [CGF].[ExclusionTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExclusionTypeGuid] [uniqueidentifier] NOT NULL,
[ExclusionTypeID] [tinyint] NOT NULL,
[ExclusionType] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExclusionTypes_ExclusionType] ON [CGF].[ExclusionTypes] ([ExclusionType]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ExclusionTypes] ON [CGF].[ExclusionTypes] ([ExclusionTypeGuid]) ON [PRIMARY]
GO
CREATE STATISTICS [spIX_ExclusionTypes_ExclusionType] ON [CGF].[ExclusionTypes] ([ExclusionType])
GO
CREATE STATISTICS [spIX_ExclusionTypes] ON [CGF].[ExclusionTypes] ([ExclusionTypeGuid])
GO
