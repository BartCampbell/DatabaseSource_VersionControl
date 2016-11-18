CREATE TABLE [stage].[MemberInfo]
(
[MemberID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEMBERNUMBER] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLASS_PLAN_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MEM_SEX_CD] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROD_ID] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ELIG_DT] [datetime2] (3) NULL,
[TERM_DT] [datetime2] (3) NULL,
[MEME_HICN] [nvarchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Row#] [bigint] NULL
) ON [PRIMARY]
GO
