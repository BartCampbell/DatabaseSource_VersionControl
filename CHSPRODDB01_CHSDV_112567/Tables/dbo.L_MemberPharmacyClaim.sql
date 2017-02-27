CREATE TABLE [dbo].[L_MemberPharmacyClaim]
(
[L_MemberPharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[H_PharmacyClaim_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LoadDate] [datetime] NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberPharmacyClaim] ADD CONSTRAINT [PK_L_MemberPharmacyClaim] PRIMARY KEY CLUSTERED  ([L_MemberPharmacyClaim_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[L_MemberPharmacyClaim] ADD CONSTRAINT [FK_MemberPharmacyClaim_H_Member_RK] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
ALTER TABLE [dbo].[L_MemberPharmacyClaim] ADD CONSTRAINT [FK_MemberPharmacyClaim_H_PharmacyClaim_RK] FOREIGN KEY ([H_PharmacyClaim_RK]) REFERENCES [dbo].[H_PharmacyClaim] ([H_PharmacyClaim_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
