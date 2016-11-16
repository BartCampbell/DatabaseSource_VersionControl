CREATE TABLE [dbo].[StagingHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__StagingHa__Creat__4B422AD5] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[StagingHash] ADD CONSTRAINT [PK_StagingHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
