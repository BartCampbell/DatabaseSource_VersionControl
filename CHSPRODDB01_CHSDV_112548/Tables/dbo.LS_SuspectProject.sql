CREATE TABLE [dbo].[LS_SuspectProject]
(
[LS_SuspectProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectProject_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Project_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectProject] ADD CONSTRAINT [PK_LS_SuspectProject] PRIMARY KEY CLUSTERED  ([LS_SuspectProject_RK]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161005-092804] ON [dbo].[LS_SuspectProject] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectProject] ADD CONSTRAINT [FK_L_SuspectProject_RK1] FOREIGN KEY ([L_SuspectProject_RK]) REFERENCES [dbo].[L_SuspectProject] ([L_SuspectProject_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
