CREATE TABLE [dbo].[ProcedureCodeList]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[ProcedureCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ShortDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (130) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (21) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SrcRowID] [int] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceID] [int] NOT NULL,
[PrimaryGrouping] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SecondaryGrouping] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
