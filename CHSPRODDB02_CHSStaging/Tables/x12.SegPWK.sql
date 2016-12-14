CREATE TABLE [x12].[SegPWK]
(
[PWK_RowID] [int] NULL,
[PWK_RowIDParent] [int] NULL,
[PWK_CentauriClientID] [int] NULL,
[PWK_FileLogID] [int] NULL,
[PWK_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_ReportTypeCode_PWK01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_ReportTransmissionCode_PWK02] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_ReportCopiesNeeded_PWK03] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_EntityIdentifierCode_PWK04] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_IdentificationCodeQualifier_PWK05] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_IdentificationCode_PWK06] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_Description_PWK07] [varchar] (80) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_ActionsIndicated_PWK08] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PWK_RequestCategoryCode_PWK09] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
