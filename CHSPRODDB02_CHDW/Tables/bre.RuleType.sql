CREATE TABLE [bre].[RuleType]
(
[RuleTypeID] [int] NOT NULL IDENTITY(1, 1),
[RuleType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_RuleType_Active] DEFAULT ((1))
) ON [PRIMARY]
GO
ALTER TABLE [bre].[RuleType] ADD CONSTRAINT [PK_RuleType] PRIMARY KEY CLUSTERED  ([RuleTypeID]) ON [PRIMARY]
GO
