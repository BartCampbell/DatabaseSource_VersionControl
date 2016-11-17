CREATE TABLE [dbo].[LS_MemberProvider]
(
[LS_MemberProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[L_MemberProvider_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PCPEffectiveDate] [date] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberProvider] ADD CONSTRAINT [PK_LS_MemberProvider] PRIMARY KEY CLUSTERED  ([LS_MemberProvider_RK], [LoadDate]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberProvider] ADD CONSTRAINT [FK_LS_MemberProvider_L_MemberProvider] FOREIGN KEY ([L_MemberProvider_RK]) REFERENCES [dbo].[L_MemberProvider] ([L_MemberProvider_RK])
GO
