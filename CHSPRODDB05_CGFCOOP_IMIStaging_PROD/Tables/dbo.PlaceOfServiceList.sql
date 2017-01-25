CREATE TABLE [dbo].[PlaceOfServiceList]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[PlaceOfServiceCode] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (19) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[SrcRowID] [int] NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadInstanceID] [int] NOT NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
