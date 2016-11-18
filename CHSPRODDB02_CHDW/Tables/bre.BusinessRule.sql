CREATE TABLE [bre].[BusinessRule]
(
[BusinessRuleID] [int] NOT NULL IDENTITY(1, 1),
[DataSourceID] [int] NOT NULL,
[TargetColumnName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AllowNullValue] [bit] NOT NULL,
[ValidationExpression] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ErrorMessage] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MinimumScore] [decimal] (12, 2) NULL,
[RuleWeight] [decimal] (12, 2) NULL,
[ParentRuleID] [int] NULL,
[Severity] [int] NULL,
[RuleTypeID] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [bre].[BusinessRule] ADD CONSTRAINT [PK_BusinessRule] PRIMARY KEY CLUSTERED  ([BusinessRuleID]) ON [PRIMARY]
GO
ALTER TABLE [bre].[BusinessRule] ADD CONSTRAINT [FK_BusinessRule_DataSource] FOREIGN KEY ([DataSourceID]) REFERENCES [bre].[DataSource] ([DataSourceID])
GO
