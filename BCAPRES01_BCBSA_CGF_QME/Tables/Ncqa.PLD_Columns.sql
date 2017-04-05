CREATE TABLE [Ncqa].[PLD_Columns]
(
[ConvertPrefix] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ConvertSuffix] [nvarchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataType] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Descr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IsRightJustified] [bit] NOT NULL,
[PldColumnGuid] [uniqueidentifier] NULL CONSTRAINT [DF_PLD_Columns_PldColumnGuid] DEFAULT (newid()),
[PldColumnID] [smallint] NOT NULL IDENTITY(1, 1),
[SourceColumn] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceTable] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValueIfNull] [nvarchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WhereClause] [nvarchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[PLD_Columns] ADD CONSTRAINT [PK_PLD_Columns] PRIMARY KEY CLUSTERED  ([PldColumnID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_PLD_Columns_PldColumnGuid] ON [Ncqa].[PLD_Columns] ([PldColumnGuid]) ON [PRIMARY]
GO
