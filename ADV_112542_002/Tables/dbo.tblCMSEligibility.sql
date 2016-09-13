CREATE TABLE [dbo].[tblCMSEligibility]
(
[Member_PK] [bigint] NOT NULL,
[EligibleMonth] [date] NOT NULL,
[Community] [bit] NULL CONSTRAINT [DF__tblCMSEligibility_Community] DEFAULT ((0)),
[Institutional] [bit] NULL CONSTRAINT [DF__tblCMSEligibility_Institutional] DEFAULT ((0)),
[ESRD] [bit] NULL CONSTRAINT [DF__tblCMSEligibility_ESRD] DEFAULT ((0)),
[HOSP] [bit] NULL CONSTRAINT [DF__tblCMSEligibility_HOSP] DEFAULT ((0)),
[NewEnr] [bit] NULL CONSTRAINT [DF__tblCMSEligibility_NewEnr] DEFAULT ((0)),
[RAF] [float] NULL,
[Payment] [float] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[tblCMSEligibility] ADD CONSTRAINT [PK__tblCMSEligibility] PRIMARY KEY CLUSTERED  ([Member_PK], [EligibleMonth]) WITH (FILLFACTOR=80) ON [PRIMARY]
GO
