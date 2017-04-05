CREATE TABLE [Member].[AttributeCategories]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DefaultMbrAttribID] [smallint] NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MbrAttribCtgyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MemberAttributes_MbrAttribCtgyGuid] DEFAULT (newid()),
[MbrAttribCtgyID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Member].[AttributeCategories] ADD CONSTRAINT [PK_Member_AttributeCategories] PRIMARY KEY CLUSTERED  ([MbrAttribCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member_AttributeCategories_Abbrev] ON [Member].[AttributeCategories] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member_AttributeCategories_Descr] ON [Member].[AttributeCategories] ([Descr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member_AttributeCategories_MbrAttribCtgyGuid] ON [Member].[AttributeCategories] ([MbrAttribCtgyGuid]) ON [PRIMARY]
GO
