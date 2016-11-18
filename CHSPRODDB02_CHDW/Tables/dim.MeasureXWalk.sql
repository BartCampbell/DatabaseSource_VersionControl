CREATE TABLE [dim].[MeasureXWalk]
(
[MeasureXWalkID] [int] NOT NULL IDENTITY(1, 1),
[MeasureID] [int] NULL,
[Component] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FieldName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MeasureXWalk] ADD CONSTRAINT [PK_MeasureXWalk] PRIMARY KEY CLUSTERED  ([MeasureXWalkID]) ON [PRIMARY]
GO
