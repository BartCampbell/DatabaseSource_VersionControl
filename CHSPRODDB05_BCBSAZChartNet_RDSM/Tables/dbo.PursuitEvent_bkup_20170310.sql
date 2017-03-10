CREATE TABLE [dbo].[PursuitEvent_bkup_20170310]
(
[PursuitEventID] [int] NOT NULL IDENTITY(5000, 1),
[PursuitID] [int] NOT NULL,
[SampleVoidFlag] [int] NULL,
[SampleVoidReasonCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbstractionStatusID] [int] NOT NULL,
[PursuitEventStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NOT NULL,
[EventDate] [datetime] NOT NULL,
[MemberMeasureSampleID] [int] NULL,
[MedicalRecordNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartStatusValueID] [int] NULL,
[ChartStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoDataFoundReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL,
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL,
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
