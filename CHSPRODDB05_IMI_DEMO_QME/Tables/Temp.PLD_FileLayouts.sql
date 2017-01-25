CREATE TABLE [Temp].[PLD_FileLayouts]
(
[ColumnEnd] [smallint] NOT NULL,
[ColumnLength] [smallint] NOT NULL,
[ColumnPosition] [smallint] NOT NULL,
[ColumnStart] [smallint] NOT NULL,
[FieldDescr] [varchar] (2048) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[FieldName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PldFileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Temp].[PLD_FileLayouts] ADD CONSTRAINT [PK_Temp_PLD_FileLayouts] PRIMARY KEY CLUSTERED  ([PldFileID], [ColumnPosition]) ON [PRIMARY]
GO
