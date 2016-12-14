CREATE TABLE [dbo].[CCAI_HCCSourceMaster]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[SubscriberNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [int] NULL,
[HCCDescription] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceData] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CommWt] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_HCCS__CommW__6E414E4F] DEFAULT ((0.000)),
[AdjCommWt] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_HCCS__AdjCo__6F357288] DEFAULT ((0.000)),
[HCCGain] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_HCCS__HCCGa__702996C1] DEFAULT ((0.000)),
[RSImpact] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_HCCS__RSImp__711DBAFA] DEFAULT ((0.000)),
[HCCSource] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MORClaimMatch] [int] NULL CONSTRAINT [DF__CCAI_HCCS__MORCl__7211DF33] DEFAULT ((0)),
[SubmissionTimeFrame] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DQFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CCAI_HCCS__DQFla__7306036C] DEFAULT ('N'),
[DQReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartialHCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PartialHCCWt] [decimal] (9, 3) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_HCCSourceMaster] ADD CONSTRAINT [UQ__CCAI_HCC__FBDF78C8F6B18220] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
