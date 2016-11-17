CREATE TABLE [dbo].[ProductivityAgentMaster]
(
[ClientID] [int] NULL,
[UserID] [int] NULL,
[UserName] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Location] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastUpdatedDate] [date] NULL,
[ContactedOfficeCnt] [int] NULL CONSTRAINT [DF__Productiv__Conta__73141DC0] DEFAULT ((0)),
[ContactedChaseCnt] [int] NULL CONSTRAINT [DF__Productiv__Conta__740841F9] DEFAULT ((0)),
[ScheduledOfficeCnt] [int] NULL CONSTRAINT [DF__Productiv__Sched__74FC6632] DEFAULT ((0)),
[ScheduledChaseCnt] [int] NULL CONSTRAINT [DF__Productiv__Sched__75F08A6B] DEFAULT ((0)),
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
