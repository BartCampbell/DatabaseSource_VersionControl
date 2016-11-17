CREATE TABLE [adv].[tblClaimDataHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblClaimD__Creat__283B47BF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblClaimDataHash] ADD CONSTRAINT [PK_tblClaimDataHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
