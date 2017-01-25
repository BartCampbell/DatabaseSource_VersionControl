CREATE TABLE [Product].[ProductClasses]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductClassGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ProductClasses_ProductClassGuid] DEFAULT (newid()),
[ProductClassID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[ProductClasses] ADD CONSTRAINT [PK_ProductClasses] PRIMARY KEY CLUSTERED  ([ProductClassID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductClasses_Abbrev] ON [Product].[ProductClasses] ([Abbrev]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductClasses_ProductClassGuid] ON [Product].[ProductClasses] ([ProductClassGuid]) ON [PRIMARY]
GO
