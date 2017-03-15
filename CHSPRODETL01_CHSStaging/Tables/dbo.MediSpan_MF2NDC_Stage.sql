CREATE TABLE [dbo].[MediSpan_MF2NDC_Stage]
(
[ndc_upc_hri] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[drug_descriptor_id] [varchar] (6) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[tee_code] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dea_class_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[desi_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rx_otc_indicator_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[generic_product_pack_code] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old_ndc_upc_hri] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_ndc_upc_hri] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[repackaged_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[id_number_format_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[third_party_restriction_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[knowledge_base_drug_code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[kdc_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[medispan_labeler_id] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[multi_source_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[name_type_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[item_status_flag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[innerpack_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[clinic_pack_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reserve1] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ppg_indicator_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[hfpg_indicatory_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dispensing_unit_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[dollar_rank_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[rx_rank_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[storage_condition_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[limited_distribution_coe] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[old_effective_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[new_effective_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_smaller_ndc_suffix] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[next_larger_ndc_suffix] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[reserve2] [varchar] (13) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[transaction_code] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[last_change_date] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_GPPC] ON [dbo].[MediSpan_MF2NDC_Stage] ([generic_product_pack_code]) INCLUDE ([ndc_upc_hri]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_ndc_upc_hri] ON [dbo].[MediSpan_MF2NDC_Stage] ([ndc_upc_hri]) ON [PRIMARY]
GO
