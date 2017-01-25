CREATE TABLE [Dictionary].[ObjectCategories]
(
[BitSeed] [tinyint] NOT NULL,
[BitValue] AS (CONVERT([bigint],power(CONVERT([bigint],(2),(0)),[BitSeed]),(0))) PERSISTED,
[Descr] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ObjectCtgyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_ObjectCategories_ObjectCtgyGuid] DEFAULT (newid()),
[ObjectCtgyID] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Dictionary].[ObjectCategories] ADD CONSTRAINT [PK_Dictionary_ObjectCategories] PRIMARY KEY CLUSTERED  ([ObjectCtgyID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dictionary_ObjectCategories_BitValue] ON [Dictionary].[ObjectCategories] ([BitValue]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Dictionary_ObjectCategories_ObjectCtgyGuid] ON [Dictionary].[ObjectCategories] ([ObjectCtgyGuid]) ON [PRIMARY]
GO
