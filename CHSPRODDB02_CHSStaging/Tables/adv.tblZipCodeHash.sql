CREATE TABLE [adv].[tblZipCodeHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblZipCod__Creat__735D6B2C] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblZipCodeHash] ADD CONSTRAINT [PK_tblZipCodeHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
