CREATE TABLE [dbo].[LS_MemberLocationType]
(
[LS_MemberLocationType_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[L_MemberLocation_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LocationType] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberLocationType] ADD CONSTRAINT [PK_LS_MemberLocationType] PRIMARY KEY CLUSTERED  ([LS_MemberLocationType_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-081156] ON [dbo].[LS_MemberLocationType] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LS_MemberLocationType] ADD CONSTRAINT [FK_L_MemberLocation_RK] FOREIGN KEY ([L_MemberLocation_RK]) REFERENCES [dbo].[L_MemberLocation] ([L_MemberLocation_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
