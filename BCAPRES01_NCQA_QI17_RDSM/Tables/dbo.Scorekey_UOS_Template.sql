CREATE TABLE [dbo].[Scorekey_UOS_Template]
(
[MemID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Meas] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payer] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Proc] [int] NULL,
[LOS] [int] NULL,
[MM] [int] NULL,
[Age] [int] NULL,
[Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
