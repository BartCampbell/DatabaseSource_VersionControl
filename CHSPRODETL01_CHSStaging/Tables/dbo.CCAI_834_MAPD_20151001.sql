CREATE TABLE [dbo].[CCAI_834_MAPD_20151001]
(
[SubscriberNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[HICNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[FirstName] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[PhoneNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Address] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[City] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[State] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ZipCode] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[DOB] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Gender] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligDateBegin] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EligDateEnd] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[EnrollmentStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CCAI_834_MAPD_20151001] ADD CONSTRAINT [PK_CCAI_834_MAPD_20151001] PRIMARY KEY CLUSTERED  ([SubscriberNumber]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
