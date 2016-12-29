CREATE TABLE [dbo].[MHHS_ChartExtract]
(
[MEMBERID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CLAIMID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PROVIDERTYPE] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SERVICEFROMDATE] [smalldatetime] NULL,
[SERVICETODATE] [smalldatetime] NULL,
[RENDERINGPROVIDERID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ICDCODE] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DXCODECATEGORY] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PAGEFROM] [smallint] NULL,
[PAGETO] [smallint] NULL,
[REN_TIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[REN_PIN] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHASEID] [varchar] (20) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CHART NAME] [varchar] (59) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Suspect_PK] [bigint] NOT NULL,
[Member_PK] [bigint] NOT NULL
) ON [PRIMARY]
GO
