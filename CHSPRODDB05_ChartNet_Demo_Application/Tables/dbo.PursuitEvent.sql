CREATE TABLE [dbo].[PursuitEvent]
(
[PursuitEventID] [int] NOT NULL IDENTITY(5000, 1),
[PursuitID] [int] NOT NULL,
[SampleVoidFlag] [int] NULL,
[SampleVoidReasonCode] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[AbstractionStatusID] [int] NOT NULL CONSTRAINT [DF__PursuitEv__Abstr__36F11965] DEFAULT ((1)),
[PursuitEventStatus] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[MeasureID] [int] NOT NULL,
[EventDate] [datetime] NOT NULL,
[MemberMeasureSampleID] [int] NULL,
[MedicalRecordNumber] [varchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ChartStatusValueID] [int] NULL,
[ChartStatus] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[NoDataFoundReason] [varchar] (255) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CreatedDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEvent_CreationDate] DEFAULT (getdate()),
[CreatedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastChangedDate] [datetime] NOT NULL CONSTRAINT [DF_PursuitEvent_LastChangedDate] DEFAULT (getdate()),
[LastChangedUser] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[WritePursuitEventStatusLog_IU]
   ON [dbo].[PursuitEvent] 
   AFTER INSERT, UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	INSERT INTO dbo.PursuitEventStatusLog
	        (PursuitEventID,
	         PursuitID,
	         AbstractionStatusID,
			 AbstractionStatusChanged,
	         ChartStatusValueID,
			 ChartStatusChanged,
	         LogDate,
	         LogUser)
    SELECT	i.PursuitEventID,
			i.PursuitID,
			i.AbstractionStatusID,
			CASE WHEN i.AbstractionStatusID <> d.AbstractionStatusID OR d.AbstractionStatusID IS NULL THEN 1 ELSE 0 END,
			i.ChartStatusValueID,
			CASE WHEN i.ChartStatusValueID <> d.ChartStatusValueID OR d.ChartStatusValueID IS NULL THEN 1 ELSE 0 END,
			COALESCE(CASE WHEN ABS(DATEDIFF(minute, COALESCE(i.LastChangedDate, i.CreatedDate), GETDATE())) < 10 THEN COALESCE(i.LastChangedDate, i.CreatedDate) END, GETDATE()) AS LogDate,
			COALESCE(i.LastChangedUser, i.CreatedUser, 'system') AS LogUser
	FROM	INSERTED AS i
			LEFT OUTER JOIN DELETED AS d
					ON i.PursuitEventID = d.PursuitEventID
	WHERE	(
				(i.AbstractionStatusID <> d.AbstractionStatusID) OR
				(i.ChartStatusValueID <> d.ChartStatusValueID) OR
				(i.AbstractionStatusID IS NOT NULL AND d.AbstractionStatusID IS NULL) OR
				(i.ChartStatusValueID IS NOT NULL AND d.ChartStatusValueID IS NULL)  OR
				(i.AbstractionStatusID IS NULL AND d.AbstractionStatusID IS NOT NULL) OR
				(i.ChartStatusValueID IS NULL AND d.ChartStatusValueID IS NOT NULL)            
			);
END
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [PK_PursuitEvent] PRIMARY KEY CLUSTERED  ([PursuitEventID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_ChartStatusValueID] ON [dbo].[PursuitEvent] ([ChartStatusValueID]) INCLUDE ([AbstractionStatusID], [EventDate], [MeasureID], [MemberMeasureSampleID], [PursuitEventID], [PursuitID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PursuitEvent_MeasureID] ON [dbo].[PursuitEvent] ([MeasureID], [EventDate]) INCLUDE ([AbstractionStatusID], [PursuitID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PursuitEvent_MemberMeasureSampleID] ON [dbo].[PursuitEvent] ([MemberMeasureSampleID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IX_PursuitEvent_PursuitID] ON [dbo].[PursuitEvent] ([PursuitID]) INCLUDE ([AbstractionStatusID]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [fk_PursuitEvent_AbstractionStatus] FOREIGN KEY ([AbstractionStatusID]) REFERENCES [dbo].[AbstractionStatus] ([AbstractionStatusID])
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [fk_PursuitEvent_ChartStatusValue] FOREIGN KEY ([ChartStatusValueID]) REFERENCES [dbo].[ChartStatusValue] ([ChartStatusValueID])
GO
ALTER TABLE [dbo].[PursuitEvent] WITH NOCHECK ADD CONSTRAINT [FK_PursuitEvent_Measure] FOREIGN KEY ([MeasureID]) REFERENCES [dbo].[Measure] ([MeasureID])
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [FK_PursuitEvent_MemberMeasureSample] FOREIGN KEY ([MemberMeasureSampleID]) REFERENCES [dbo].[MemberMeasureSample] ([MemberMeasureSampleID])
GO
ALTER TABLE [dbo].[PursuitEvent] ADD CONSTRAINT [FK_PursuitEvent_Pursuit] FOREIGN KEY ([PursuitID]) REFERENCES [dbo].[Pursuit] ([PursuitID])
GO
