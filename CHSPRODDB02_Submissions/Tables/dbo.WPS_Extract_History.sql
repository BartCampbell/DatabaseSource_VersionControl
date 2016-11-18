CREATE TABLE [dbo].[WPS_Extract_History]
(
[Member_ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Individual ID] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Claim_ID] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ProviderType] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Service From Dt] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Service To Dt] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN Provider ID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX Code Qualifier] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[ICD Code] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DX Code Category] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[DescribeASR] [varchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Page From] [smallint] NULL,
[Page To] [smallint] NULL
) ON [PRIMARY]
GO
