CREATE TABLE [Ncqa].[CodingECTs]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[MeasureYear] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Measure] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableLetter] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Description] [varchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TypeOfCode] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Code] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PrimaryOrSec] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ValidBilling] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PageNumber] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateModified] [datetime] NULL,
[FileID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[CodingECTs] ADD CONSTRAINT [PK_CodingECTs] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_CodingECTs_FileID] ON [Ncqa].[CodingECTs] ([FileID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Ncqa_CodingECTs_TableName] ON [Ncqa].[CodingECTs] ([TableName], [MeasureYear], [TypeOfCode]) INCLUDE ([Measure], [TableLetter]) ON [PRIMARY]
GO
