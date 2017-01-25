CREATE TABLE [dbo].[MeasureColumnClientTemplate]
(
[TemplateID] [int] NOT NULL IDENTITY(1, 1),
[TemplateName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TemplateText] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureColumnClientTemplate] ADD CONSTRAINT [PK_MeasureColumnClientTemplate] PRIMARY KEY CLUSTERED  ([TemplateID]) ON [PRIMARY]
GO
