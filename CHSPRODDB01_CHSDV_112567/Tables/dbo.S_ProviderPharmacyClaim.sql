CREATE TABLE [dbo].[S_ProviderPharmacyClaim]
(
[S_ProviderPharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Provider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CR-PROV-ID] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CR-PROV-ID-LOC] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CR-PROVIDER-NPI-ID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderPharmacyClaim] ADD CONSTRAINT [PK_S_ProviderPharmacyClaim] PRIMARY KEY CLUSTERED  ([S_ProviderPharmacyClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_ProviderPharmacyClaim] ADD CONSTRAINT [FK_S_ProviderPharmacyClaim_H_Provider] FOREIGN KEY ([H_Provider_RK]) REFERENCES [dbo].[H_Provider] ([H_Provider_RK])
GO
