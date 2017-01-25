CREATE TABLE [dbo].[MasterForeignKeys]
(
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_MasterForeignKeys_IsEnabled] DEFAULT ((1)),
[KeyColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MasterForeignKeyGuid] [uniqueidentifier] NOT NULL CONSTRAINT [DF_MasterForeignKeys_ForeignKeyGuid] DEFAULT (newid()),
[MasterForeignKeyID] [smallint] NOT NULL IDENTITY(1, 1),
[SourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:		Kriz, Mike
-- Create date: 6/1/2012
-- Description:	Automatically inserts any child columns matching the same column name as the KeyColumn.
-- =============================================
CREATE TRIGGER [dbo].[MasterForeignKeys_AutoInsertLinks_I]
   ON [dbo].[MasterForeignKeys] 
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

    INSERT INTO dbo.MasterForeignKeyLinks 
			(ChildColumn,
			IsEnabled,
			MasterForeignKeyID,
			SourceSchema,
			SourceTable)
    SELECT	COLUMN_NAME AS ChildColumn,
			1 AS IsEnabled,
			MFK.MasterForeignKeyID,
			C.TABLE_SCHEMA AS SourceSchema,
			C.TABLE_NAME AS SouceTable
    FROM	INFORMATION_SCHEMA.COLUMNS AS C
			INNER JOIN INFORMATION_SCHEMA.TABLES AS T
					ON C.TABLE_CATALOG = T.TABLE_CATALOG AND
						C.TABLE_NAME = T.TABLE_NAME AND
						C.TABLE_SCHEMA = T.TABLE_SCHEMA AND
						T.TABLE_TYPE = 'BASE TABLE'
			--INNER JOIN dbo.MasterForeignKeys AS MFK
			INNER JOIN INSERTED AS MFK
					ON C.COLUMN_NAME = MFK.KeyColumn
	WHERE	NOT	(
					(C.TABLE_SCHEMA = MFK.SourceSchema) AND 
					(C.TABLE_NAME = MFK.SourceTable)
				)
	ORDER BY C.TABLE_SCHEMA, C.TABLE_NAME, C.COLUMN_NAME;
	
END
GO
ALTER TABLE [dbo].[MasterForeignKeys] ADD CONSTRAINT [PK_MasterForeignKeys] PRIMARY KEY CLUSTERED  ([MasterForeignKeyID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_MasterForeignKeys] ON [dbo].[MasterForeignKeys] ([Descr]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MasterForeignKeys_KeyColumn] ON [dbo].[MasterForeignKeys] ([KeyColumn]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MasterForeignKeys_MasterForeignKeyGuid] ON [dbo].[MasterForeignKeys] ([MasterForeignKeyGuid]) ON [PRIMARY]
GO
