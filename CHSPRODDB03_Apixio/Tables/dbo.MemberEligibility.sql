CREATE TABLE [dbo].[MemberEligibility]
(
[Pat_ID] [varchar] (30) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[First_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Last_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Gender] [char] (1) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[DOB] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[HPlan] [varchar] (5) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[HPlan_Name] [varchar] (100) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Eligibility_Start_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Eligibility_End_Date] [varchar] (10) COLLATE SQL_Latin1_General_CP437_CI_AI NULL,
[Alt_ID_1] [int] NOT NULL,
[Alt_ID_label_1] [varchar] (25) COLLATE SQL_Latin1_General_CP437_CI_AI NOT NULL,
[Date_Refreshed] [datetime] NOT NULL,
[Date_Retreived] [datetime] NULL,
[RecID] [int] NOT NULL IDENTITY(1, 1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MemberEligibility] ADD CONSTRAINT [PK_MemberEligibility_] PRIMARY KEY CLUSTERED  ([RecID]) ON [PRIMARY]
GO
