CREATE TABLE [dbo].[FHN_CloseTheGap_IncentiveTierPayment]
(
[RecID] [int] NOT NULL IDENTITY(1, 1),
[GroupID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DisplayName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FullMeasureDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AchieveP50] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AchieveP75] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[GapsClosedCnt] [int] NULL CONSTRAINT [DF__FHN_Close__GapsC__3CC09802] DEFAULT ((0)),
[TotalGapstoCloseCnt] [int] NULL CONSTRAINT [DF__FHN_Close__Total__3DB4BC3B] DEFAULT ((0)),
[TierFlag] [int] NULL,
[TierAmount] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_Close__TierA__3EA8E074] DEFAULT ((0.00)),
[ActualTierPayment] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_Close__Actua__3F9D04AD] DEFAULT ((0.00)),
[PotentialTierFlag] [int] NULL,
[PotentialTierAmount] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_Close__Poten__409128E6] DEFAULT ((0.00)),
[PotentialTierPayment] [decimal] (9, 2) NULL CONSTRAINT [DF__FHN_Close__Poten__41854D1F] DEFAULT ((0.00)),
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FHN_CloseTheGap_IncentiveTierPayment] ADD CONSTRAINT [UQ__FHN_Clos__360414FEC350CC6A] UNIQUE NONCLUSTERED  ([RecID]) ON [PRIMARY]
GO
