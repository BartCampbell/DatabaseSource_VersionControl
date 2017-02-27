CREATE TABLE [dbo].[S_Memberesi1900Details]
(
[S_Memberesi1900Details_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberLastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberFirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberMiddleInitial] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberDateofBirth] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberGender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CardHolderID] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MemberNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Memberesi1900Details] ADD CONSTRAINT [PK_S_Memberesi19007Details] PRIMARY KEY CLUSTERED  ([S_Memberesi1900Details_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Memberesi1900Details] ADD CONSTRAINT [FK_S_Memberesi19007Details_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
