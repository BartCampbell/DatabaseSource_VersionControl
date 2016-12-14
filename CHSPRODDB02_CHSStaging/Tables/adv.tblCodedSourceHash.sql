CREATE TABLE [adv].[tblCodedSourceHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblCodedS__Creat__30D08DC0] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblCodedSourceHash] ADD CONSTRAINT [PK_tblCodedSourceHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
