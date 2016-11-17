CREATE TABLE [dbo].[L_ClaimDataMember]
(
[L_ClaimDataMember_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_ClaimData_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimDataMember] ADD CONSTRAINT [PK_L_ClaimDataMember] PRIMARY KEY CLUSTERED  ([L_ClaimDataMember_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_ClaimDataMember] ADD CONSTRAINT [FK_H_ClaimData_RK1] FOREIGN KEY ([H_ClaimData_RK]) REFERENCES [dbo].[H_ClaimData] ([H_ClaimData_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_ClaimDataMember] ADD CONSTRAINT [FK_H_Member_RK1] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
