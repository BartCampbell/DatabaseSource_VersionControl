CREATE TABLE [dbo].[L_MemberHEDIS]
(
[L_MemberHEDIS_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_HEDIS_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberHEDIS] ADD CONSTRAINT [PK_L_MemberHEDIS] PRIMARY KEY CLUSTERED  ([L_MemberHEDIS_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberHEDIS] ADD CONSTRAINT [FK_L_MemberHEDIS_H_HEDIS] FOREIGN KEY ([H_HEDIS_RK]) REFERENCES [dbo].[H_HEDIS] ([H_HEDIS_RK])
GO
ALTER TABLE [dbo].[L_MemberHEDIS] ADD CONSTRAINT [FK_L_MemberHEDIS_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
