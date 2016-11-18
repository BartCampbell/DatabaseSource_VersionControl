CREATE TABLE [dim].[MeasureClass]
(
[MeasureClassID] [int] NOT NULL IDENTITY(1, 1),
[MeasureClassCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MeasureClass] ADD CONSTRAINT [PK_MeasureClass] PRIMARY KEY CLUSTERED  ([MeasureClassID]) ON [PRIMARY]
GO
