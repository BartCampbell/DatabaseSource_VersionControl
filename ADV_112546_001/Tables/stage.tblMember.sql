CREATE TABLE [stage].[tblMember]
(
[HICNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [date] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChaseID] [bigint] NULL,
[ChasePiority] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MedicalRecordID] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PROVIDER_SPECIALTY] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Eff_Date] [date] NULL,
[Exp_Date] [date] NULL,
[Contract_Code] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
