CREATE TABLE [dbo].[FHN_CareCollaboration_IncentivePayment]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[PCPID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullMeasureDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Denominator] [int] NULL CONSTRAINT [DF__FHN_CareC__Denom__538FBA18] DEFAULT ((0)),
[Numerator] [int] NULL CONSTRAINT [DF__FHN_CareC__Numer__5483DE51] DEFAULT ((0)),
[IncentiveAmt] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_CareC__Incen__5578028A] DEFAULT ((0.00)),
[PotentialAmt] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_CareC__Poten__566C26C3] DEFAULT ((0.00)),
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FHN_CareCollaboration_IncentivePayment] ADD CONSTRAINT [UQ__FHN_Care__360414FE3397B256] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
