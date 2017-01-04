CREATE TABLE [ref].[Condition]
(
[ConditionID] [int] NOT NULL IDENTITY(1, 1),
[ConditionCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Condition] [varchar] (500) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [datetime] NOT NULL,
[EffectiveEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [ref].[Condition] ADD CONSTRAINT [PK_Condition] PRIMARY KEY CLUSTERED  ([ConditionID]) ON [PRIMARY]
GO
