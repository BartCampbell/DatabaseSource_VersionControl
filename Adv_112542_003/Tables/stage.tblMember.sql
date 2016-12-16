CREATE TABLE [stage].[tblMember]
(
[HICNumber] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[DOB] [date] NULL,
[Gender] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[PID] [varchar] (20) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Eff_Date] [date] NULL,
[Exp_Date] [date] NULL
) ON [PRIMARY]
GO
