CREATE TABLE [Ncqa].[CodingFiles]
(
[FileID] [int] NOT NULL IDENTITY(1, 1),
[SourceName] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[MeasureYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Measure] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableLetter] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SourceType] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DateImported] [datetime] NULL,
[IsEnabled] [bit] NOT NULL CONSTRAINT [DF_CodingFiles_IsEnabled] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[CodingFiles] ADD CONSTRAINT [PK_Ncqa_CodingFiles] PRIMARY KEY CLUSTERED  ([FileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_CodingFiles_TableName] ON [Ncqa].[CodingFiles] ([TableName], [MeasureYear]) ON [PRIMARY]
GO
