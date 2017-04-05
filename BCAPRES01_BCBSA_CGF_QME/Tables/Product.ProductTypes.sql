CREATE TABLE [Product].[ProductTypes]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductClassID] [tinyint] NOT NULL,
[ProductTypeGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ProductTypes_ProductTypeGuid] DEFAULT (newid()),
[ProductTypeID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[ProductTypes] ADD CONSTRAINT [PK_ProductTypes] PRIMARY KEY CLUSTERED  ([ProductTypeID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_ProductTypes_Abbrev] ON [Product].[ProductTypes] ([Abbrev]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductTypes_ProductClassID] ON [Product].[ProductTypes] ([ProductClassID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ProductTypes_ProductTypeGuid] ON [Product].[ProductTypes] ([ProductTypeGuid]) ON [PRIMARY]
GO
