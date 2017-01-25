CREATE TABLE [dbo].[MemberProvider]
(
[MemberProviderID] [int] NOT NULL IDENTITY(1, 1),
[MemberID] [int] NOT NULL,
[ProviderID] [int] NOT NULL,
[Client] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DataSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DateEffective] [datetime] NOT NULL,
[DateTerminated] [datetime] NULL,
[HedisMeasureID] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RowID] [bigint] NULL,
[ProviderMedicalGroupID] [int] NULL,
[SourceSystem] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerAffiliationID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerEnrollID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerNetworkID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPAffiliationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AffilicationPCPFlag] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CustomerProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberProvider] ADD CONSTRAINT [pk_MemberProvider] PRIMARY KEY CLUSTERED  ([MemberProviderID]) ON [PRIMARY]
GO
CREATE STATISTICS [sp_pk_MemberProvider] ON [dbo].[MemberProvider] ([MemberProviderID])
GO
