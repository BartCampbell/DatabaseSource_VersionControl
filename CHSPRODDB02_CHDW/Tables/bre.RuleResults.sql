CREATE TABLE [bre].[RuleResults]
(
[RuleResultsID] [int] NOT NULL IDENTITY(1, 1),
[BusinessRuleID] [int] NOT NULL,
[BusinessKeyValue] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TargetColumnValue] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[ResultDate] [datetime] NOT NULL CONSTRAINT [DF_RuleResults_ResultDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [bre].[RuleResults] ADD CONSTRAINT [PK_RuleResults] PRIMARY KEY CLUSTERED  ([RuleResultsID]) ON [PRIMARY]
GO
