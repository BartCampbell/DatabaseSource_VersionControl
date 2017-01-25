CREATE TABLE [Log].[EntityEligible]
(
[BatchID] [int] NOT NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_EntityEligible_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollGroupID] [int] NULL,
[EntityBaseID] [bigint] NOT NULL,
[Iteration] [int] NULL,
[LastSegBeginDate] [datetime] NULL,
[LastSegEndDate] [datetime] NULL,
[LogID] [bigint] NOT NULL IDENTITY(1, 1),
[LogTime] [datetime] NOT NULL CONSTRAINT [DF_Log_EntityEligible_LogTime] DEFAULT (getdate()),
[LogUser] [nvarchar] (128) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL CONSTRAINT [DF_Log_EntityEligible_LogUser] DEFAULT (suser_sname()),
[OwnerID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Log].[EntityEligible] ADD CONSTRAINT [PK_Log_EntityEligible] PRIMARY KEY CLUSTERED  ([LogID]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_Log_EntityEligible_BatchID] ON [Log].[EntityEligible] ([BatchID], [DataRunID], [DataSetID], [EntityBaseID], [EnrollGroupID], [LogID]) ON [PRIMARY]
GO
