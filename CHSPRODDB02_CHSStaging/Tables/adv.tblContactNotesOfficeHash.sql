CREATE TABLE [adv].[tblContactNotesOfficeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblContac__Creat__34A11EA4] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblContactNotesOfficeHash] ADD CONSTRAINT [PK_tblContactNotesOfficeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
