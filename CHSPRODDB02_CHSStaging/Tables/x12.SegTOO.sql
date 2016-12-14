CREATE TABLE [x12].[SegTOO]
(
[TOO_RowID] [int] NULL,
[TOO_RowIDParent] [int] NULL,
[TOO_CentauriClientID] [int] NULL,
[TOO_FileLogID] [int] NULL,
[TOO_TransactionImplementationConventionReference] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_TransactionControlNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_LoopID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_CodeListQualifierCode_TOO01] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_IndustryCode_TOO02] [varchar] (30) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_ToothSurfaceCode_TOO0301] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_ToothSurfaceCode_TOO0302] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_ToothSurfaceCode_TOO0303] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_ToothSurfaceCode_TOO0304] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[TOO_ToothSurfaceCode_TOO0305] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
