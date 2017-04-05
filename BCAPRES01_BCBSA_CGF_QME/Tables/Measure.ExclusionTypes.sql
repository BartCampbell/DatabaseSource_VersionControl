CREATE TABLE [Measure].[ExclusionTypes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ExclusionTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ExclusionTypes_ExclusionTypeGuid] DEFAULT (newid()),
[ExclusionTypeID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Measure].[ExclusionTypes] ADD CONSTRAINT [PK_ExclusionTypes] PRIMARY KEY CLUSTERED  ([ExclusionTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ExclusionTypes_Abbrev] ON [Measure].[ExclusionTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ExclusionTypes_ExclusionTypeGuid] ON [Measure].[ExclusionTypes] ([ExclusionTypeGuid]) ON [PRIMARY]
GO
