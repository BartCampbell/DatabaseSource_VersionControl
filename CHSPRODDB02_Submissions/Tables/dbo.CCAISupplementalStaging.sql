CREATE TABLE [dbo].[CCAISupplementalStaging]
(
[SourceRefID] [bigint] NOT NULL,
[MemberID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [smalldatetime] NULL,
[DOSTo] [smalldatetime] NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SourceKey] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
