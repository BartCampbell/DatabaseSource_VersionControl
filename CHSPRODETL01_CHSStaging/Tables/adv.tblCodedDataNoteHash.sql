CREATE TABLE [adv].[tblCodedDataNoteHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblCodedD__Creat__2C0BD8A3] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedDataNoteHash] ADD CONSTRAINT [PK_tblCodedDataNoteHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
