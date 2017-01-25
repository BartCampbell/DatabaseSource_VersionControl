CREATE TABLE [Member].[Attributes]
(
[Abbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MbrAttribCtgyID] [tinyint] NOT NULL,
[MbrAttribGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Attributes_MbrAttribGuid] DEFAULT (newid()),
[MbrAttribID] [smallint] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [Member].[Attributes] ADD CONSTRAINT [PK_Member_Attributes] PRIMARY KEY CLUSTERED  ([MbrAttribID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member_Attributes_Abbrev] ON [Member].[Attributes] ([Abbrev]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Member_Attributes_MbrAttribCtgyID] ON [Member].[Attributes] ([MbrAttribCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Member_Attributes_MbrAttribGuid] ON [Member].[Attributes] ([MbrAttribGuid]) ON [PRIMARY]
GO
