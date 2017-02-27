CREATE TABLE [adv].[StagingHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[TableName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ClientID] [int] NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__StagingHa__Creat__26DD0F32] DEFAULT (getdate()),
[RecordSource] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
