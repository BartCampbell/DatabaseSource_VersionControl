CREATE TABLE [adv].[tblIssueResponseOfficeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblIssueR__Creat__43E36234] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblIssueResponseOfficeHash] ADD CONSTRAINT [PK_tblIssueResponseOfficeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
