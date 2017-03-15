CREATE TABLE [dbo].[CCAI_MemberMaster]
(
[RecordID] [int] NOT NULL IDENTITY(1, 1),
[SubscriberNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HICN] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligBeginDate] [int] NULL,
[EligEndDate] [int] NULL,
[PCPID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroup] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderGroupName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberType] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ActiveFlag] [int] NULL,
[ContractNumber] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PaymentDate] [int] NULL,
[HOSPICEIND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ESRDIND] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AgeGroup] [int] NULL,
[MedicaidInd] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[JanRiskScore] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_Memb__JanRi__78BEDCC2] DEFAULT ((0.000)),
[PredRiskScore] [decimal] (9, 3) NULL CONSTRAINT [DF__CCAI_Memb__PredR__79B300FB] DEFAULT ((0.000)),
[RAFactor] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ORECInd] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TotalPayment] [decimal] (9, 2) NULL CONSTRAINT [DF__CCAI_Memb__Total__7AA72534] DEFAULT ((0.000)),
[TotalHCCsMOR] [int] NULL CONSTRAINT [DF__CCAI_Memb__Total__7B9B496D] DEFAULT ((0)),
[TotalRawHCCWt] [float] NULL CONSTRAINT [DF__CCAI_Memb__Total__7C8F6DA6] DEFAULT ((0.000)),
[ExcludeFlag] [int] NULL CONSTRAINT [DF__CCAI_Memb__Exclu__7D8391DF] DEFAULT ((0)),
[ExcludeReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_MemberMaster] ADD CONSTRAINT [UQ__CCAI_Mem__FBDF78C801E5A5FC] UNIQUE NONCLUSTERED  ([RecordID]) ON [PRIMARY]
GO
