CREATE TABLE [dbo].[RAPSCIRawHA_20170131]
(
[SourceRefID] [bigint] NOT NULL,
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [smalldatetime] NULL,
[DOSTo] [smalldatetime] NULL,
[ProviderNPI] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CodedData_PK] [bigint] NOT NULL,
[SourceKey] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
