CREATE TABLE [Internal].[EntityEligible]
(
[BatchID] [int] NOT NULL,
[BitProductLines] [bigint] NOT NULL CONSTRAINT [DF_EntityEligible_BitProductLines] DEFAULT ((0)),
[DataRunID] [int] NOT NULL,
[DataSetID] [int] NOT NULL,
[EnrollGroupID] [int] NOT NULL,
[EntityBaseID] [bigint] NOT NULL,
[LastSegBeginDate] [datetime] NULL,
[LastSegEndDate] [datetime] NULL,
[SpId] [int] NOT NULL CONSTRAINT [DF_EntityEnrolled_SpId] DEFAULT (@@spid)
) ON [PRIMARY]
GO
ALTER TABLE [Internal].[EntityEligible] ADD CONSTRAINT [PK_Internal_EntityEligible] PRIMARY KEY CLUSTERED  ([SpId], [EntityBaseID], [EnrollGroupID]) ON [PRIMARY]
GO
