CREATE TABLE [dbo].[AetnaCombinedInvoiceBackup]
(
[MEMBER_ID] [varchar] (75) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_INDIVIDUAL_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SUB_PROJECT_NAME] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_NPI] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_TIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHASE_ID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Billing Source] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ Cost_of_Billed_Service ] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_Date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Vendor_Name] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_Category] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[YHA_Invoice_Number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Invoice_number] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [bigint] NULL
) ON [PRIMARY]
GO
