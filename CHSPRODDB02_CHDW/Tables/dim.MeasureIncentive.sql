CREATE TABLE [dim].[MeasureIncentive]
(
[MeasureIncentiveID] [int] NOT NULL IDENTITY(1, 1),
[MeasureID] [int] NULL,
[TargetValue] [int] NULL,
[TargetName] [varchar] (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EffectiveBegin] [datetime] NULL,
[EffectiveEnd] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dim].[MeasureIncentive] ADD CONSTRAINT [PK_MeasureIncentive] PRIMARY KEY CLUSTERED  ([MeasureIncentiveID]) ON [PRIMARY]
GO
