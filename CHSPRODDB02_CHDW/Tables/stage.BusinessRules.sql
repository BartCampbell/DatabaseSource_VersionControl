CREATE TABLE [stage].[BusinessRules]
(
[ExecutionOrder] [int] NOT NULL,
[BusinessRule] [varchar] (max) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RunTime] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [stage].[BusinessRules] ADD CONSTRAINT [PK_BusinessRules] PRIMARY KEY CLUSTERED  ([ExecutionOrder]) ON [PRIMARY]
GO
