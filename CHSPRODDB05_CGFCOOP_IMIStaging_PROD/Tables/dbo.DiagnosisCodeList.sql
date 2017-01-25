CREATE TABLE [dbo].[DiagnosisCodeList]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[DiagnosisCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShortDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (150) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SrcRowID] [int] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceID] [int] NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
