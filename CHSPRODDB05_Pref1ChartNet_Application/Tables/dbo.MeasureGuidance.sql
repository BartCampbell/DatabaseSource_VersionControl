CREATE TABLE [dbo].[MeasureGuidance]
(
[MeasureID] [int] NOT NULL,
[TvfSchema] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TvfName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MeasureGuidance] ADD CONSTRAINT [PK_MeasureGuidance] PRIMARY KEY CLUSTERED  ([MeasureID]) ON [PRIMARY]
GO
