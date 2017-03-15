CREATE TABLE [x12].[SegMEA]
(
[MEA_RowID] [int] NULL,
[MEA_RowIDParent] [int] NULL,
[MEA_CentauriClientID] [int] NULL,
[MEA_FileLogID] [int] NULL,
[MEA_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementReferenceIDCode_MEA01] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementQualifer_MEA02] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementValue_MEA03] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_CompositeUnitOfMeasure_MEA04] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_RangeMinimum_MEA05] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_RangeMaximum_MEA06] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementSignificanceCode_MEA07] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementAttributeCode_MEA08] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_SurfaceLayerPositioinCode_MEA09] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_MeasurementMethodOrDevice_MEA10] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_CodeListQualifierCode_MEA11] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEA_IndustryCode_MEA12] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
