CREATE TABLE [ref].[RxHCCListing]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[HCCVersion] [int] NULL,
[HCCVersionYear] [int] NULL,
[CCType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CC] [int] NULL,
[CCDesc] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommWt_NonDualAged] [decimal] (9, 3) NULL CONSTRAINT [DF__RxHCCList__CommW__26DAAD2D] DEFAULT ((0.000)),
[CommWt_NonDualDisabled] [decimal] (9, 3) NULL CONSTRAINT [DF__RxHCCList__CommW__27CED166] DEFAULT ((0.000)),
[CommWt_DualAged] [decimal] (9, 3) NULL CONSTRAINT [DF__RxHCCList__CommW__28C2F59F] DEFAULT ((0.000)),
[CommWt_DualDisabled] [decimal] (9, 3) NULL CONSTRAINT [DF__RxHCCList__CommW__29B719D8] DEFAULT ((0.000)),
[InstWt] [decimal] (9, 3) NULL CONSTRAINT [DF__RxHCCList__InstW__2AAB3E11] DEFAULT ((0.000))
) ON [PRIMARY]
GO
ALTER TABLE [ref].[RxHCCListing] ADD CONSTRAINT [UQ__RxHCCLis__360414FE6A6CB0D4] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
