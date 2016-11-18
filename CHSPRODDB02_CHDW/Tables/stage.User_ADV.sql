CREATE TABLE [stage].[User_ADV]
(
[CentauriUserid] [int] NULL,
[Username] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[sch_Name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ismale] [bit] NULL,
[ClientID] [int] NULL,
[LoadDate] [datetime] NULL
) ON [PRIMARY]
GO
