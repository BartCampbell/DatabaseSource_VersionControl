CREATE TABLE [stage].[WellCare_CodingValidation]
(
[CHARTID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_LAST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBER_FIRST] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGE] [float] NULL,
[DATE_OF_SERVICE] [datetime] NULL,
[DX] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HCC] [float] NULL,
[DXCodeNotes] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DECISION] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Validate Y/N] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[If Not Validated, Reason] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SEQ_MEMB_ID] [float] NULL,
[HICN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[unique_hcc] [float] NULL
) ON [PRIMARY]
GO
