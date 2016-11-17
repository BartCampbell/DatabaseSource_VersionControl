CREATE TABLE [adv].[tblDocumentTypeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblDocume__Creat__3C42406C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblDocumentTypeHash] ADD CONSTRAINT [PK_tblDocumentTypeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
