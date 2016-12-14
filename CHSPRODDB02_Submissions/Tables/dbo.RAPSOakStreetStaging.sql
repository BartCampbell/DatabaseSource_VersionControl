CREATE TABLE [dbo].[RAPSOakStreetStaging]
(
[HPLan] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ClaimNumber] [int] NULL,
[MemberID] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLast] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirst] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [datetime] NULL,
[MemberGender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligDateFrom] [datetime] NULL,
[EligDateTo] [datetime] NULL,
[EligType] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [datetime] NULL,
[DOSTo] [datetime] NULL,
[RAPSProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCodeVersion] [int] NULL,
[SubmittableFlag] [bit] NULL,
[RAPSOakStreetStagingID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSOakStreetStaging] ADD CONSTRAINT [PK_RAPSOakStreetStaging] PRIMARY KEY CLUSTERED  ([RAPSOakStreetStagingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
