CREATE TABLE [dbo].[ClientProcessInstanceMetrics]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[DateCreated] [datetime] NULL,
[LoadInstanceID] [int] NULL,
[MetricName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MetricValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProcedureName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TableName] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ExpectedMetricValue] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ClientProcessInstanceMetrics] ADD CONSTRAINT [PK__ClientProcessIns__1CC7330E] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
