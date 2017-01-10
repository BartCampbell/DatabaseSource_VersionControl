CREATE TABLE [stage].[ProviderMasterConsolidated]
(
[ProviderID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Lastname] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Firstname] [varchar] (75) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[NPI] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Address] [varchar] (250) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Zip] [int] NULL,
[ContactNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[FaxNumber] [varchar] (120) COLLATE SQL_Latin1_General_CP437_CI_AI NULL
) ON [PRIMARY]
GO
