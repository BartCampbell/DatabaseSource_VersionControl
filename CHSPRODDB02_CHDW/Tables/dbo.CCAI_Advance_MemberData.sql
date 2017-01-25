CREATE TABLE [dbo].[CCAI_Advance_MemberData]
(
[Member_PK] [bigint] NOT NULL,
[HICNumber] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Lastname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Firstname] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [date] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
