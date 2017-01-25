CREATE TABLE [dbo].[RAPSCIFileRaw]
(
[SourceRefID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [datetime] NULL,
[DOSTo] [datetime] NULL,
[ProviderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ProviderNPI] [int] NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceKey] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
