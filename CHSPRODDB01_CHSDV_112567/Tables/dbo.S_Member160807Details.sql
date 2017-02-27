CREATE TABLE [dbo].[S_Member160807Details]
(
[S_Member160807Details_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[LoadDate] [datetime] NOT NULL,
[H_Member_RK] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3001-MEMBER-ID] [varchar] (11) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3005-MBR-NAME] [varchar] (31) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3005-MBR-LAST-NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3005-MBR-FIRST-NAME] [varchar] (15) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3005-MBR-INIT] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-3006-MBR-ADDRESS] [varchar] (79) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-MBR-3006-ADDR-LINE1] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-MBR-3006-ADDR-LINE2] [varchar] (25) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3008-MBR-CITY] [varchar] (18) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3009-MBR-STATE] [varchar] (2) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[    CL-EXT-3010-MBR-ZIP] [varchar] (9) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[      CL-EXT-3010-MBR-ZIP5] [varchar] (5) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[      CL-EXT-3010-MBR-ZIP4] [varchar] (4) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1016-BIRTH-DT] [varchar] (8) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CL-EXT-1018-SEX] [varchar] (1) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[HashDiff] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordSource] [varchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[RecordEndDate] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Member160807Details] ADD CONSTRAINT [PK_S_Member160807Details] PRIMARY KEY CLUSTERED  ([S_Member160807Details_RK]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[S_Member160807Details] ADD CONSTRAINT [FK_S_Member160807Details_H_Member] FOREIGN KEY ([H_Member_RK]) REFERENCES [dbo].[H_Member] ([H_Member_RK])
GO
