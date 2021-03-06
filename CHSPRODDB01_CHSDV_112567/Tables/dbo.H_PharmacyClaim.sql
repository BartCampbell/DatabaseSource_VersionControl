CREATE TABLE [dbo].[H_PharmacyClaim]
(
[H_PharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[PharmacyClaim_BK] [int] NULL,
[ClientPharmacyClaimID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL CONSTRAINT [DF_H_PharmacyClaim_LoadDate] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[H_PharmacyClaim] ADD CONSTRAINT [PK_H_PharmacyClaim] PRIMARY KEY CLUSTERED  ([H_PharmacyClaim_RK]) ON [PRIMARY]
GO
