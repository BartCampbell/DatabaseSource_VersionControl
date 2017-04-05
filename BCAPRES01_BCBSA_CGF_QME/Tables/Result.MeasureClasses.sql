CREATE TABLE [Result].[MeasureClasses]
(
[Descr] [varchar] (130) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasClassID] [smallint] NOT NULL,
[SubMeasClassDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SubMeasClassID] [smallint] NULL,
[TopMeasClassDescr] [varchar] (64) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TopMeasClassID] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [Result].[MeasureClasses] ADD CONSTRAINT [PK_Result_MeasureClasses] PRIMARY KEY CLUSTERED  ([MeasClassID]) ON [PRIMARY]
GO
