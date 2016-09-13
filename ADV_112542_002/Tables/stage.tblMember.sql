CREATE TABLE [stage].[tblMember]
(
[HICNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [date] NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Eff_Date] [date] NULL,
[Exp_Date] [date] NULL
) ON [PRIMARY]
GO
