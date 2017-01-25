CREATE TABLE [dbo].[copay_list_2013]
(
[ReportedClaimNumber] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (28) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[VendorType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ServiceType] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[AmountCoinsurance] [money] NULL,
[AmountCopay] [money] NULL,
[AmountDeductible] [money] NULL
) ON [PRIMARY]
GO
