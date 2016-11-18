CREATE TABLE [dbo].[RAPSOakStreetSubmissionStaging]
(
[HPlan] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PatientControlNbr] [varchar] (40) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberHICN] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDOB] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSFrom] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOSTo] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSProviderTypeCode] [char] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCode] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RiskAssessmentCode] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RAPSOakStreetSubmissionStagingID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RAPSOakStreetSubmissionStaging] ADD CONSTRAINT [PK_RAPSOakStreetSubmissionStaging] PRIMARY KEY CLUSTERED  ([RAPSOakStreetSubmissionStagingID]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
