CREATE TABLE [stage].[MemberEligibility]
(
[CentauriMemberID] [int] NOT NULL,
[Payor] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[EffectiveStartDate] [int] NOT NULL,
[EffectiveEndDate] [int] NOT NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NetworkID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
