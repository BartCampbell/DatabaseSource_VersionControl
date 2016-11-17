CREATE TABLE [adv].[tblIssueResponseHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblIssueR__Creat__47B3F318] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblIssueResponseHash] ADD CONSTRAINT [PK_tblIssueResponseHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
