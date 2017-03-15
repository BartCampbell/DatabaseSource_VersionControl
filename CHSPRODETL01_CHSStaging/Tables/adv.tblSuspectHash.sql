CREATE TABLE [adv].[tblSuspectHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__Creat__1E7CD35B] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectHash] ADD CONSTRAINT [PK_tblSuspectHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
