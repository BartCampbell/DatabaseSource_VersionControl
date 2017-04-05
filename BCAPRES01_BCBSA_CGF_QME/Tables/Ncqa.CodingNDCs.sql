CREATE TABLE [Ncqa].[CodingNDCs]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[MeasureYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableLetter] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[BrandName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[GenericName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Category] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Route] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DrugId] [nvarchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Dosage] [decimal] (18, 6) NULL,
[UOM] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Form] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FileID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[CodingNDCs] ADD CONSTRAINT [PK_CodingNDCs] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_CodingNDCs_FileID] ON [Ncqa].[CodingNDCs] ([FileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_CodingNDCs_TableName] ON [Ncqa].[CodingNDCs] ([TableName], [MeasureYear]) INCLUDE ([Measure], [TableLetter]) ON [PRIMARY]
GO
