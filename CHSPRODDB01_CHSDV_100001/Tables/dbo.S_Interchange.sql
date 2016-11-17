CREATE TABLE [dbo].[S_Interchange]
(
[S_Interchange_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[H_Interchange_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[LoadDate] [datetime] NOT NULL,
[ISA01_AuthorizationInformationQualifier] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA02_AuthorizationInformation] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA03_SecurityInformationQualifier] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA04_SecurityInformation] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA05_InterchangeSenderIdQualifier] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA06_InterchangeSenderId] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA07_InterchangeReceiverIdQualifier] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA08_InterchangeReceiverId] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA09_InterchangeDate] [char] (6) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA10_InterchangeTime] [char] (4) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA11_RepetitionSeparator] [char] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA12_InterchangeControlVersionNumber] [varchar] (5) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA13_InterchangeControlNumber] [varchar] (9) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA14_AcknowledgmentRequested] [char] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA15_InterchangeUsageIndicator] [char] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[ISA16_ComponentElementSeparator] [char] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS01_FunctionalIdentifierCode] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS02_ApplicationsendersCode] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS03_ApplicationReceiversCode] [varchar] (15) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS04_Date] [varchar] (8) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS05_Time] [varchar] (4) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS06_GroupControlNumber] [varchar] (9) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS07_ResponsibleAgencyCode] [varchar] (2) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[GS08_VersionReleaseIdCode] [varchar] (12) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Interchange] ADD CONSTRAINT [PK_S_Interchange] PRIMARY KEY CLUSTERED  ([S_Interchange_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Interchange] ADD CONSTRAINT [FK_S_Interchange_H_Interchange] FOREIGN KEY ([H_Interchange_RK]) REFERENCES [dbo].[H_Interchange] ([H_Interchange_RK])
GO
