CREATE TABLE [dbo].[MeasureComponent]
(
[MeasureComponentID] [int] NOT NULL IDENTITY(1, 1),
[MeasureID] [int] NOT NULL,
[ComponentName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SortKey] [int] NOT NULL,
[DataEntryControl] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DataEntryAssembly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DestinationTable] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Title] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Language] [varchar] (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataProviderClass] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataProviderAssembly] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AdditionalDataControl] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TabDisplayTitle] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnabledOnWebsite] [bit] NOT NULL CONSTRAINT [DF__MeasureCo__Enabl__316D4A39] DEFAULT ((1)),
[EnabledOnTabs] [bit] NOT NULL CONSTRAINT [DF_MeasureComponent_EnableOnTabs] DEFAULT ((1)),
[EnabledOnReviews] [bit] NOT NULL CONSTRAINT [DF_MeasureComponent_EnableOnReviews] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponent] ADD CONSTRAINT [PK_MeasureComponent] PRIMARY KEY CLUSTERED  ([MeasureComponentID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_MeasureComponent] ON [dbo].[MeasureComponent] ([ComponentName]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureComponent] WITH NOCHECK ADD CONSTRAINT [FK_MeasureComponent_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureID])
GO
