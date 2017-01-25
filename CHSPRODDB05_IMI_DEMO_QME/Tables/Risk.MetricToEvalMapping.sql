CREATE TABLE [Risk].[MetricToEvalMapping]
(
[AggregateID] [tinyint] NOT NULL CONSTRAINT [DF_MetricToEvalMapping_AggregateID] DEFAULT ((1)),
[ClassPeriodID] [tinyint] NOT NULL,
[DefaultValue] [decimal] (18, 12) NOT NULL CONSTRAINT [DF_MetricToEvalMapping_DefaultValue] DEFAULT ((0)),
[EvalTypeID] [tinyint] NOT NULL,
[MetricID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Risk].[MetricToEvalMapping] ADD CONSTRAINT [PK_Risk_MetricToEvalMapping] PRIMARY KEY CLUSTERED  ([EvalTypeID], [MetricID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_Risk_MetricToEvalMapping_ClassPeriod] ON [Risk].[MetricToEvalMapping] ([ClassPeriodID]) ON [PRIMARY]
GO
