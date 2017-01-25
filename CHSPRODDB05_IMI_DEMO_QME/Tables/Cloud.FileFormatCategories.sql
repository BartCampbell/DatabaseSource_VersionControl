CREATE TABLE [Cloud].[FileFormatCategories]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FileFormatCtgyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_FileFormatCategories_FileFormatCtgyGuid] DEFAULT (newid()),
[FileFormatCtgyID] [tinyint] NOT NULL,
[MatchEngine] [bit] NOT NULL CONSTRAINT [DF_FileFormatCategories_MatchEngine] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Cloud].[FileFormatCategories] ADD CONSTRAINT [PK_FileFormatCategories] PRIMARY KEY CLUSTERED  ([FileFormatCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFormatCategories_Abbrev] ON [Cloud].[FileFormatCategories] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_FileFormatCategories] ON [Cloud].[FileFormatCategories] ([FileFormatCtgyGuid]) ON [PRIMARY]
GO
