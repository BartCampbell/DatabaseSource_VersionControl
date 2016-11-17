CREATE TABLE [dbo].[L_Member_MOR]
(
[L_Member_MOR_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_MOR_Header_RK] [varchar] (32) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (256) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_Member_MOR] ADD CONSTRAINT [PK_L_Member_MOR] PRIMARY KEY CLUSTERED  ([L_Member_MOR_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_Member_MOR] ADD CONSTRAINT [FK_L_Member_MOR_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
ALTER TABLE [dbo].[L_Member_MOR] ADD CONSTRAINT [FK_L_Member_MOR_H_MOR_Header] FOREIGN KEY ([H_MOR_Header_RK]) REFERENCES [dbo].[H_MOR_Header] ([H_MOR_Header_RK])
GO
