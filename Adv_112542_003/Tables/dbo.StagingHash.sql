CREATE TABLE [dbo].[StagingHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__StagingHa__Creat__36670980] DEFAULT (getdate())
) ON [PRIMARY]
GO
