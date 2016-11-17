CREATE TABLE [dbo].[LS_MemberContactType]
(
[LS_MemberContactType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_MemberContact_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ContactType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberContactType] ADD CONSTRAINT [PK_LS_MemberContactType] PRIMARY KEY CLUSTERED  ([LS_MemberContactType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081127] ON [dbo].[LS_MemberContactType] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberContactType] ADD CONSTRAINT [FK_L_MemberContact_RK] FOREIGN KEY ([L_MemberContact_RK]) REFERENCES [dbo].[L_MemberContact] ([L_MemberContact_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
