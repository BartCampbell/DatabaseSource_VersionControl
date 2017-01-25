CREATE TABLE [CGF_REP].[ReportVariableLog]
(
[RowID] [int] NOT NULL IDENTITY(1, 1),
[RunDate] [datetime] NULL,
[ProcName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var1Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var1Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var2Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var2Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var3Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var3Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var4Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var4Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var5Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var5Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var6Name] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var6Val] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var7name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var7Val] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var8name] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Var8Val] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
