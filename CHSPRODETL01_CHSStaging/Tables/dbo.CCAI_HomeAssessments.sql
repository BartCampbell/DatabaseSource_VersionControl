CREATE TABLE [dbo].[CCAI_HomeAssessments]
(
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [smalldatetime] NULL,
[DOSTo] [smalldatetime] NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedData_PK] [bigint] NOT NULL,
[SourceKey] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CentauriMemberID] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSSubmittedFlag] [int] NULL CONSTRAINT [DF__CCAI_Home__RAPSS__5AE46118] DEFAULT ((0)),
[DXCodeCapturedFlag] [int] NULL CONSTRAINT [DF__CCAI_Home__DXCod__5BD88551] DEFAULT ((0)),
[HCCFlag] [int] NULL CONSTRAINT [DF__CCAI_Home__HCCFl__6D031153] DEFAULT ((0)),
[DQFlag] [int] NULL CONSTRAINT [DF__CCAI_Home__DQFla__6DF7358C] DEFAULT ((0)),
[DQReason] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CCAI_Home__DQRea__6EEB59C5] DEFAULT (''),
[HCC] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IncludeFlag] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL CONSTRAINT [DF__CCAI_Home__Inclu__6FDF7DFE] DEFAULT ('Y')
) ON [PRIMARY]
GO
