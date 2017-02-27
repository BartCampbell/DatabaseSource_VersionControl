CREATE TABLE [dbo].[S_MemberPharmacyClaim]
(
[S_MemberPharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CR-MEMBER-ID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CR-MEMBER-BIRTH-DATE] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Last Name] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member First Name] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Middle Initial] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Gender] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Age] [varchar] (3) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member PCP Assignment] [varchar] (10) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member Program] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB Default] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberPharmacyClaim] ADD CONSTRAINT [PK_S_MemberPharmacyClaim] PRIMARY KEY CLUSTERED  ([S_MemberPharmacyClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberPharmacyClaim] ADD CONSTRAINT [FK_S_MemberPharmacyClaim_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
