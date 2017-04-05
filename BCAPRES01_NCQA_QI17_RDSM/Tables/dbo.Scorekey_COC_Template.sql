CREATE TABLE [dbo].[Scorekey_COC_Template]
(
[MemID] [varchar] (16) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Meas] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Payer] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Exc] [bit] NULL,
[Cor] [bit] NULL,
[ClinCat] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CostInp] [int] NULL,
[CostIEM] [int] NULL,
[CostOEM] [int] NULL,
[CostIProc] [int] NULL,
[CostOProc] [int] NULL,
[CostPharm] [numeric] (12, 2) NULL,
[FreqInp] [int] NULL,
[FreqED] [int] NULL,
[Cond1] [int] NULL,
[MM] [int] NULL,
[MMP] [int] NULL,
[Age] [int] NULL,
[Sex] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
