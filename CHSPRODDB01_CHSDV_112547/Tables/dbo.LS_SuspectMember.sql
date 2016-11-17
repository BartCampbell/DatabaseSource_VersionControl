CREATE TABLE [dbo].[LS_SuspectMember]
(
[LS_SuspectMember_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_SuspectMember_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Suspect_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Active] [char] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectMember] ADD CONSTRAINT [PK_LS_SuspectMember] PRIMARY KEY CLUSTERED  ([LS_SuspectMember_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161005-092740] ON [dbo].[LS_SuspectMember] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_SuspectMember] ADD CONSTRAINT [FK_L_SuspectMember_RK1] FOREIGN KEY ([L_SuspectMember_RK]) REFERENCES [dbo].[L_SuspectMember] ([L_SuspectMember_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
