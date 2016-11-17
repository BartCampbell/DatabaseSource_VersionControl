CREATE TABLE [dbo].[L_SuspectUserInvoiceVendor]
(
[L_SuspectUserInvoiceVendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_User_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_InvoiceVendor_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUserInvoiceVendor] ADD CONSTRAINT [PK_L_SuspectUserInvoiceVendor] PRIMARY KEY CLUSTERED  ([L_SuspectUserInvoiceVendor_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_SuspectUserInvoiceVendor] ADD CONSTRAINT [FK_H_InvoiceVendor_RK1] FOREIGN KEY ([H_InvoiceVendor_RK]) REFERENCES [dbo].[H_InvoiceVendor] ([H_InvoiceVendor_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectUserInvoiceVendor] ADD CONSTRAINT [FK_H_Suspect_RK6] FOREIGN KEY ([H_Suspect_RK]) REFERENCES [dbo].[H_Suspect] ([H_Suspect_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_SuspectUserInvoiceVendor] ADD CONSTRAINT [FK_H_User_RK12] FOREIGN KEY ([H_User_RK]) REFERENCES [dbo].[H_User] ([H_User_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
