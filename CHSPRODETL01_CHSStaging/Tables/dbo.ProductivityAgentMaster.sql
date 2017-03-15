CREATE TABLE [dbo].[ProductivityAgentMaster]
(
[ClientID] [int] NULL,
[UserID] [int] NULL,
[UserName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProjectGroup] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [date] NULL,
[ContactedOfficeCnt] [int] NULL CONSTRAINT [DF__Productiv__Conta__216FE54D] DEFAULT ((0)),
[ContactedChaseCnt] [int] NULL CONSTRAINT [DF__Productiv__Conta__22640986] DEFAULT ((0)),
[ScheduledOfficeCnt] [int] NULL CONSTRAINT [DF__Productiv__Sched__23582DBF] DEFAULT ((0)),
[ScheduledChaseCnt] [int] NULL CONSTRAINT [DF__Productiv__Sched__244C51F8] DEFAULT ((0)),
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
