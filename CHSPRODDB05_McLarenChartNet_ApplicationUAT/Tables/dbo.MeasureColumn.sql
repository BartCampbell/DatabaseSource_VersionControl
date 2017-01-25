CREATE TABLE [dbo].[MeasureColumn]
(
[MeasureColumnID] [int] NOT NULL IDENTITY(1, 1),
[MeasureComponentID] [int] NOT NULL,
[ColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DisplayText] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortKey] [int] NOT NULL,
[Visible] [bit] NOT NULL CONSTRAINT [DF_MeasureColumn_Visible] DEFAULT ((1)),
[FormatString] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientTemplateID] [int] NULL,
[RequiresValidation] [bit] NOT NULL CONSTRAINT [DF_MeasureColumn_RequiresValidation] DEFAULT ((0)),
[TableColumnName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableColumnRefSource] [nvarchar] (1024) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableColumnRefId] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableColumnRefValue] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [CreateDate_def] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureColumn] ADD CONSTRAINT [PK_MeasureColumn] PRIMARY KEY CLUSTERED  ([MeasureColumnID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureColumn] ADD CONSTRAINT [FK_MeasureColumn_MeasureColumnClientTemplate] FOREIGN KEY ([ClientTemplateID]) REFERENCES [dbo].[MeasureColumnClientTemplate] ([TemplateID])
GO
ALTER TABLE [dbo].[MeasureColumn] WITH NOCHECK ADD CONSTRAINT [FK_MeasureColumn_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
