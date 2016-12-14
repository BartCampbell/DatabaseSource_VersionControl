CREATE TABLE [dbo].[MediSpan_MF2GPPC_Stage]
(
[generic_product_pack_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[package_size] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_size_uom] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_quantity] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unit_dose_unit_use_pkg_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[package_description_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[generic_product_identifier] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reserve] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_code] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_change_date] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GPI] ON [dbo].[MediSpan_MF2GPPC_Stage] ([generic_product_identifier]) INCLUDE ([generic_product_pack_code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GPPC] ON [dbo].[MediSpan_MF2GPPC_Stage] ([generic_product_pack_code]) INCLUDE ([generic_product_identifier]) ON [PRIMARY]
GO
