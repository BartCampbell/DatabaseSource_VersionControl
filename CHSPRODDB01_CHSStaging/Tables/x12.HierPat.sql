CREATE TABLE [x12].[HierPat]
(
[HierPat_RowID] [int] NULL,
[HierPat_RowIDParent] [int] NULL,
[HierPat_CentauriClientID] [int] NULL,
[HierPat_FileLogID] [int] NULL,
[HierPat_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_HierarchicalIDNumber_HL01] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_HierarchicalParentIDNumber_HL02] [varchar] (12) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_HierarchicalLevelCode_HL03] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_HierarchicalChildCode_HL04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_IndividualRelationshipCode_PAT01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_PatientLocationCode_PAT02] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_EmploymentStatusCode_PAT03] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_StudentStatusCode_PAT04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_DateTimePeriodFormatQualifier_PAT05] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_DateTimePeriod_PAT06] [varchar] (35) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_UnitOrBasisforMeasurementCode_PAT07] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_Weight_PAT08] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HierPat_YesNoConditionOrResponseCode_PAT09] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
