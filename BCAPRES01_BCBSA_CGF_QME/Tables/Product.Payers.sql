CREATE TABLE [Product].[Payers]
(
[Abbrev] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Descr] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PayerGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_Payers_PayerGuid] DEFAULT (newid()),
[PayerID] [smallint] NOT NULL,
[ProductLineID] [smallint] NOT NULL,
[ProductTypeID] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Product].[Payers] ADD CONSTRAINT [PK_Payers] PRIMARY KEY CLUSTERED  ([PayerID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Payers_Abbrev] ON [Product].[Payers] ([Abbrev]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Payers_PayerGuid] ON [Product].[Payers] ([PayerGuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Payers_ProductTypeID] ON [Product].[Payers] ([ProductTypeID]) ON [PRIMARY]
GO
