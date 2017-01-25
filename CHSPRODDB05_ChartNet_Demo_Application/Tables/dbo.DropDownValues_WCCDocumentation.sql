CREATE TABLE [dbo].[DropDownValues_WCCDocumentation]
(
[DocumentationTypeID] [int] NOT NULL,
[MeasureComponentID] [int] NOT NULL,
[SortKey] [int] NOT NULL CONSTRAINT [DF_DropDownValues_WCCDocumentation_SortKey] DEFAULT ((0)),
[Description] [nvarchar] (300) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_WCCDocumentation] ADD CONSTRAINT [PK_DropDownValues_WCCDocumentation] PRIMARY KEY CLUSTERED  ([DocumentationTypeID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DropDownValues_WCCDocumentation] ADD CONSTRAINT [FK_DropDownValues_WCCDocumentation_MeasureComponent] FOREIGN KEY ([MeasureComponentID]) REFERENCES [dbo].[MeasureComponent] ([MeasureComponentID])
GO
