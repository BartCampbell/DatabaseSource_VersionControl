CREATE TABLE [dbo].[S_MemberDetail]
(
[S_MemberDetail_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_ID] [varchar] (22) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Member_PK] [bigint] NULL,
[Latitude] [float] NULL,
[Longitude] [float] NULL,
[parent_gardian] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[preferred_practitioner_gender] [tinyint] NULL,
[does_not_speak_english] [bit] NULL,
[unable_to_determine_language] [bit] NULL,
[speaking_language] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[language_line_will_be_required_for_the_visit] [bit] NULL,
[plan_unable_to_validate_client_vendor_relationship] [bit] NULL,
[preferred_method_of_contact] [tinyint] NULL,
[permission_to_leave_voicemail] [bit] NULL,
[place_of_assessment_is_not_members_home] [bit] NULL,
[members_power_of_attorney] [bit] NULL,
[POA_Name] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Client_PK] [tinyint] NULL,
[Eff_Date] [date] NULL,
[Exp_date] [date] NULL,
[HashDiff] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberDetail] ADD CONSTRAINT [PK_S_MemberDetail] PRIMARY KEY CLUSTERED  ([S_MemberDetail_RK]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20161003-080938] ON [dbo].[S_MemberDetail] ([HashDiff]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_MemberDetail] ADD CONSTRAINT [FK_H_Member_RK8] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK]) ON DELETE CASCADE ON UPDATE CASCADE
GO
