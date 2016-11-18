CREATE TABLE [bre].[ClientRuleMapping]
(
[ClientRuleMappingID] [int] NOT NULL IDENTITY(1, 1),
[ClientID] [int] NOT NULL,
[Process] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[BusinessRuleID] [int] NOT NULL,
[Active] [bit] NOT NULL CONSTRAINT [DF_ClientRuleMapping_Active] DEFAULT ((1)),
[CreateDate] [datetime] NOT NULL,
[LastUpdate] [datetime] NOT NULL,
[UpdateBy] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [bre].[ClientRuleMapping] ADD CONSTRAINT [PK_ClientRuleMapping] PRIMARY KEY CLUSTERED  ([ClientRuleMappingID]) ON [PRIMARY]
GO
ALTER TABLE [bre].[ClientRuleMapping] ADD CONSTRAINT [FK_ClientRuleMapping_BusinessRule] FOREIGN KEY ([BusinessRuleID]) REFERENCES [bre].[BusinessRule] ([BusinessRuleID])
GO
