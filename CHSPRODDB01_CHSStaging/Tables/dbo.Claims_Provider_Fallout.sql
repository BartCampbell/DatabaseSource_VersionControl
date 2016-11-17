CREATE TABLE [dbo].[Claims_Provider_Fallout]
(
[Claim Number] [int] NOT NULL,
[Member ID#] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Rendering Provider NPI] [char] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SequenceNumber] [int] NOT NULL,
[FalloutDate] [datetime] NOT NULL,
[Reason] [varchar] (24) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
