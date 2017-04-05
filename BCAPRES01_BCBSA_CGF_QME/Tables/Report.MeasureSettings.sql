CREATE TABLE [Report].[MeasureSettings]
(
[KeyFieldID] [tinyint] NOT NULL,
[MeasureID] [int] NOT NULL,
[ShowHeadersEachMetric] [bit] NOT NULL CONSTRAINT [DF_MeasureSettings_ShowHeadersEachMetric] DEFAULT ((0)),
[ShowOnReport] [bit] NOT NULL CONSTRAINT [DF_MeasureSettings_ShowOnReport] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [Report].[MeasureSettings] ADD CONSTRAINT [PK_MeasureSettings] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
