CREATE TABLE [Ncqa].[MeasureProductLineListing]
(
[MeasureAbbrev] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProductLine] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Ncqa].[MeasureProductLineListing] ADD CONSTRAINT [PK_MeasureProductLineListing] PRIMARY KEY CLUSTERED  ([MeasureAbbrev], [ProductLine]) ON [PRIMARY]
GO
