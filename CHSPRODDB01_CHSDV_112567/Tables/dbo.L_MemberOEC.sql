CREATE TABLE [dbo].[L_MemberOEC]
(
[L_MemberOEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_OEC_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberOEC] ADD CONSTRAINT [PK_L_MemberOEC] PRIMARY KEY CLUSTERED  ([L_MemberOEC_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberOEC] ADD CONSTRAINT [FK_L_MemberOEC_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
ALTER TABLE [dbo].[L_MemberOEC] ADD CONSTRAINT [FK_L_MemberOEC_H_OEC] FOREIGN KEY ([H_OEC_RK]) REFERENCES [dbo].[H_OEC] ([H_OEC_RK])
GO
