CREATE TABLE [adv].[tblSuspectInvoiceInfoHash]
(
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[CreateDate] [datetime] NULL CONSTRAINT [DF__tblSuspec__Creat__130B20AF] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [adv].[tblSuspectInvoiceInfoHash] ADD CONSTRAINT [PK_tblSuspectInvoiceInfoHash] PRIMARY KEY CLUSTERED  ([HashDiff]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
