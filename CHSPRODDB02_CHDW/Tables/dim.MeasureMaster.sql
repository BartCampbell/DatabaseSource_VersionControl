CREATE TABLE [dim].[MeasureMaster]
(
[MeasureID] [int] NOT NULL IDENTITY(1, 1),
[MeasureClassID] [int] NULL,
[MeasureLevel] [int] NULL,
[MeasureCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureDescription] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LevelRef] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MeasureMaster] ADD CONSTRAINT [PK_MeasureMaster] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
ALTER TABLE [dim].[MeasureMaster] ADD CONSTRAINT [FK_MeasureMaster_MeasureClass] FOREIGN KEY ([MeasureClassID]) REFERENCES [dim].[MeasureClass] ([MeasureClassID])
GO
