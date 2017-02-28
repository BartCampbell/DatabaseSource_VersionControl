SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO







-- ==========================================================================================================
-- Author:		Dwight Staggs
-- Create date: 2017-01-27
-- Description:	Load MAO004 Header, Detail, and Trailer tables from raw data table for
--				Phase 2 format MAO004 files
--
--	Modifications
--	=============
--
--	Date			Who					What
--	==========		=============	==========================================================================
--	2017-01-09		DStaggs			Created proc
--
-- ==========================================================================================================

CREATE PROCEDURE [dbo].[spLoadMAO004_Phase2]

AS
	SET NOCOUNT ON;

	--	Error handling...
	DECLARE
			@SPReturnCode		INT,
			@ErrorNumber		INT,
			@ErrorSeverity		INT,
			@ErrorState			INT,
			@ErrorProcedure		NVARCHAR(128),
			@ErrorLine			INT,
			@ErrorMessage		NVARCHAR(4000)

    BEGIN 

		BEGIN TRY
	
			--
			--	Load Header
			--

			INSERT INTO	
				dbo.MAO004_Header
			( 
				InboundFileName ,
				LoadDateTime ,
				RecordType ,
				ReportId ,
				MAContractId ,
				ReportDate ,
				ReportDesc ,
				SubmissionFileType
			)

			SELECT
				InboundFileName,
				LoadDateTime,
				RecordType = SUBSTRING(MAO004_RawData, 1, 1),
				ReportId = SUBSTRING(MAO004_RawData, 3, 7),
				MAContractId = SUBSTRING(MAO004_RawData, 11, 5),
				ReportDate = SUBSTRING(MAO004_RawData, 17, 8),
				ReportDesc = SUBSTRING(MAO004_RawData, 26, 53),
				SubmissionFileType = SUBSTRING(MAO004_RawData, 111, 4)
			FROM 
				dbo.MAO004_Raw
			WHERE
				 SUBSTRING(MAO004_RawData, 1, 1) = '0'
			AND	 ProcessedFlag = 0
           
		   --

			UPDATE
				dbo.MAO004_Raw
			SET	
				ProcessedFlag = '1'
			WHERE
				 SUBSTRING(MAO004_RawData, 1, 1) = '0'
			AND	 ProcessedFlag = 0
		                                                                                                     
																											 		--
			--
			--	Load Detail
			--

			INSERT INTO	
				dbo.MAO004_Detail
				( 
					HeaderId ,
					RecordType ,
					ReportId ,
					MAContractId ,
					HICN ,
					EncounterICN ,
					EncounterTypeSwitch ,
					OriginalEncounterICN ,
					PlanSubmissionDate ,
					ProcessingDate ,
					BeginDateOfService ,
					EndDateOfService ,
					ClaimType ,
					DiagnosisCode ,
					DiagnosisICD ,
					AddDeleteFlag ,
					DiagnosisCode1 ,
					DiagnosisICD1 ,
					AddDeleteFlag1 ,
					DiagnosisCode2 ,
					DiagnosisICD2 ,
					AddDeleteFlag2 ,
					DiagnosisCode3 ,
					DiagnosisICD3 ,
					AddDeleteFlag3 ,
					DiagnosisCode4 ,
					DiagnosisICD4 ,
					AddDeleteFlag4 ,
					DiagnosisCode5 ,
					DiagnosisICD5 ,
					AddDeleteFlag5 ,
					DiagnosisCode6 ,
					DiagnosisICD6 ,
					AddDeleteFlag6 ,
					DiagnosisCode7 ,
					DiagnosisICD7 ,
					AddDeleteFlag7 ,
					DiagnosisCode8 ,
					DiagnosisICD8 ,
					AddDeleteFlag8 ,
					DiagnosisCode9 ,
					DiagnosisICD9 ,
					AddDeleteFlag9 ,
					DiagnosisCode10 ,
					DiagnosisICD10 ,
					AddDeleteFlag10 ,
					DiagnosisCode11 ,
					DiagnosisICD11 ,
					AddDeleteFlag11 ,
					DiagnosisCode12 ,
					DiagnosisICD12 ,
					AddDeleteFlag12 ,
					DiagnosisCode13 ,
					DiagnosisICD13 ,
					AddDeleteFlag13 ,
					DiagnosisCode14 ,
					DiagnosisICD14 ,
					AddDeleteFlag14 ,
					DiagnosisCode15 ,
					DiagnosisICD15 ,
					AddDeleteFlag15 ,
					DiagnosisCode16 ,
					DiagnosisICD16 ,
					AddDeleteFlag16 ,
					DiagnosisCode17 ,
					DiagnosisICD17 ,
					AddDeleteFlag17 ,
					DiagnosisCode18 ,
					DiagnosisICD18 ,
					AddDeleteFlag18 ,
					DiagnosisCode19 ,
					DiagnosisICD19 ,
					AddDeleteFlag19 ,
					DiagnosisCode20 ,
					DiagnosisICD20 ,
					AddDeleteFlag20 ,
					DiagnosisCode21 ,
					DiagnosisICD21 ,
					AddDeleteFlag21 ,
					DiagnosisCode22 ,
					DiagnosisICD22 ,
					AddDeleteFlag22 ,
					DiagnosisCode23 ,
					DiagnosisICD23 ,
					AddDeleteFlag23 ,
					DiagnosisCode24 ,
					DiagnosisICD24 ,
					AddDeleteFlag24
				)
			SELECT
					HeaderId = h.HeaderId,
					RecordType = SUBSTRING(MAO004_RawData, 1, 1) ,
					ReportId = SUBSTRING(MAO004_RawData, 3, 7) ,
					MAContractId = SUBSTRING(MAO004_RawData, 11, 5) ,
					HICN = SUBSTRING(MAO004_RawData, 17, 12) ,
					EncounterICN = SUBSTRING(MAO004_RawData, 30, 44) ,
					EncounterTypeSwitch = SUBSTRING(MAO004_RawData, 75, 1) ,
					OriginalEncounterICN = SUBSTRING(MAO004_RawData, 77, 44) ,
					PlanSubmissionDate = SUBSTRING(MAO004_RawData, 122, 8) ,
					ProcessingDate = SUBSTRING(MAO004_RawData, 131, 8) ,
					BeginDateOfService = SUBSTRING(MAO004_RawData, 140, 8) ,
					EndDateOfService = SUBSTRING(MAO004_RawData, 149, 8) ,
					ClaimType = SUBSTRING(MAO004_RawData, 158, 1) ,
					DiagnosisCode = SUBSTRING(MAO004_RawData, 160, 7) ,
					DiagnosisICD = SUBSTRING(MAO004_RawData, 168, 1) ,
					AddDeleteFlag = SUBSTRING(MAO004_RawData, 170, 1) ,
					DiagnosisCode1 = SUBSTRING(MAO004_RawData, 172, 7) ,
					DiagnosisICD1 = SUBSTRING(MAO004_RawData, 180, 1) ,
					AddDeleteFlag1 = SUBSTRING(MAO004_RawData, 182, 1) ,
					DiagnosisCode2 = SUBSTRING(MAO004_RawData, 184, 7) ,
					DiagnosisICD2 = SUBSTRING(MAO004_RawData, 192, 1) ,
					AddDeleteFlag2 = SUBSTRING(MAO004_RawData, 194, 1) ,
					DiagnosisCode3 = SUBSTRING(MAO004_RawData, 196, 7) ,
					DiagnosisICD3 = SUBSTRING(MAO004_RawData, 204, 1) ,
					AddDeleteFlag3 = SUBSTRING(MAO004_RawData, 206, 1) ,
					DiagnosisCode4 = SUBSTRING(MAO004_RawData, 208, 7) ,
					DiagnosisICD4 = SUBSTRING(MAO004_RawData, 216, 1) ,
					AddDeleteFlag4 = SUBSTRING(MAO004_RawData, 218, 1) ,
					DiagnosisCode5 = SUBSTRING(MAO004_RawData, 220, 7) ,
					DiagnosisICD5 = SUBSTRING(MAO004_RawData, 228, 1) ,
					AddDeleteFlag5 = SUBSTRING(MAO004_RawData, 230, 1) ,
					DiagnosisCode6 = SUBSTRING(MAO004_RawData, 232, 7) ,
					DiagnosisICD6 = SUBSTRING(MAO004_RawData, 240, 1) ,
					AddDeleteFlag6 = SUBSTRING(MAO004_RawData, 242, 1) ,
					DiagnosisCode7 = SUBSTRING(MAO004_RawData, 244, 7) ,
					DiagnosisICD7 = SUBSTRING(MAO004_RawData, 252, 1) ,
					AddDeleteFlag7 = SUBSTRING(MAO004_RawData, 254, 1) ,
					DiagnosisCode8 = SUBSTRING(MAO004_RawData, 256, 7) ,
					DiagnosisICD8 = SUBSTRING(MAO004_RawData, 264, 1) ,
					AddDeleteFlag8 = SUBSTRING(MAO004_RawData, 266, 1) ,
					DiagnosisCode9 = SUBSTRING(MAO004_RawData, 268, 7) ,
					DiagnosisICD9 = SUBSTRING(MAO004_RawData, 276, 1) ,
					AddDeleteFlag9 = SUBSTRING(MAO004_RawData, 278, 1) ,
					DiagnosisCode10 = SUBSTRING(MAO004_RawData, 280, 7) ,
					DiagnosisICD10 = SUBSTRING(MAO004_RawData, 288, 1) ,
					AddDeleteFlag10 = SUBSTRING(MAO004_RawData, 290, 1) ,
					DiagnosisCode11 = SUBSTRING(MAO004_RawData, 292, 7) ,
					DiagnosisICD11 = SUBSTRING(MAO004_RawData, 300, 1) ,
					AddDeleteFlag11 = SUBSTRING(MAO004_RawData, 302, 1) ,
					DiagnosisCode12 = SUBSTRING(MAO004_RawData, 304, 7) ,
					DiagnosisICD12 = SUBSTRING(MAO004_RawData, 312, 1) ,
					AddDeleteFlag12 = SUBSTRING(MAO004_RawData, 314, 1) ,
					DiagnosisCode13 = SUBSTRING(MAO004_RawData, 316, 7) ,
					DiagnosisICD13 = SUBSTRING(MAO004_RawData, 324, 1) ,
					AddDeleteFlag13 = SUBSTRING(MAO004_RawData, 326, 1) ,
					DiagnosisCode14 = SUBSTRING(MAO004_RawData, 328, 7) ,
					DiagnosisICD14 = SUBSTRING(MAO004_RawData, 336, 1) ,
					AddDeleteFlag14 = SUBSTRING(MAO004_RawData, 338, 1) ,
					DiagnosisCode15 = SUBSTRING(MAO004_RawData, 340, 7) ,
					DiagnosisICD15 = SUBSTRING(MAO004_RawData, 348, 1) ,
					AddDeleteFlag15 = SUBSTRING(MAO004_RawData, 350, 1) ,
					DiagnosisCode16 = SUBSTRING(MAO004_RawData, 352, 7) ,
					DiagnosisICD16 = SUBSTRING(MAO004_RawData, 360, 1) ,
					AddDeleteFlag16 = SUBSTRING(MAO004_RawData, 362, 1) ,
					DiagnosisCode17 = SUBSTRING(MAO004_RawData, 364, 7) ,
					DiagnosisICD17 = SUBSTRING(MAO004_RawData, 372, 1) ,
					AddDeleteFlag17 = SUBSTRING(MAO004_RawData, 374, 1) ,
					DiagnosisCode18 = SUBSTRING(MAO004_RawData, 376, 7) ,
					DiagnosisICD18 = SUBSTRING(MAO004_RawData, 384, 1) ,
					AddDeleteFlag18 = SUBSTRING(MAO004_RawData, 386, 1) ,
					DiagnosisCode19 = SUBSTRING(MAO004_RawData, 388, 7) ,
					DiagnosisICD19 = SUBSTRING(MAO004_RawData, 396, 1) ,
					AddDeleteFlag19 = SUBSTRING(MAO004_RawData, 398, 1) ,
					DiagnosisCode20 = SUBSTRING(MAO004_RawData, 400, 7) ,
					DiagnosisICD20 = SUBSTRING(MAO004_RawData, 408, 1) ,
					AddDeleteFlag20 = SUBSTRING(MAO004_RawData, 410, 1) ,
					DiagnosisCode21 = SUBSTRING(MAO004_RawData, 412, 7) ,
					DiagnosisICD21 = SUBSTRING(MAO004_RawData, 420, 1) ,
					AddDeleteFlag21 = SUBSTRING(MAO004_RawData, 422, 1) ,
					DiagnosisCode22 = SUBSTRING(MAO004_RawData, 424, 7) ,
					DiagnosisICD22 = SUBSTRING(MAO004_RawData, 432, 1) ,
					AddDeleteFlag22 = SUBSTRING(MAO004_RawData, 434, 1) ,
					DiagnosisCode23 = SUBSTRING(MAO004_RawData, 436, 7) ,
					DiagnosisICD23 = SUBSTRING(MAO004_RawData, 444, 1) ,
					AddDeleteFlag23 = SUBSTRING(MAO004_RawData, 446, 1) ,
					DiagnosisCode24 = SUBSTRING(MAO004_RawData, 448, 7) ,
					DiagnosisICD24 = SUBSTRING(MAO004_RawData, 456, 1) ,
					AddDeleteFlag24 = SUBSTRING(MAO004_RawData, 458, 1)
			FROM	
				dbo.MAO004_Raw		r
			INNER JOIN	
				dbo.MAO004_Header	h
				ON r.InboundFileName = h.InboundFileName
				AND r.LoadDateTime = h.LoadDateTime
			WHERE	SUBSTRING(MAO004_RawData, 1, 1) = '1'
					AND ProcessedFlag = 0;

			UPDATE
				dbo.MAO004_Raw
			SET	
				ProcessedFlag = '1'
			WHERE
				 SUBSTRING(MAO004_RawData, 1, 1) = '1'
			AND	 ProcessedFlag = 0


			--
			--	Load Trailer
			--
			INSERT INTO	
				dbo.MAO004_Trailer
						( HeaderId ,
						  RecordType ,
						  ReportId ,
						  MAContractId ,
						  TotalNumberOfRecords
						)
			SELECT
					HeaderId = h.HeaderId,
					RecordType = SUBSTRING(MAO004_RawData, 1, 1) ,
					ReportId = SUBSTRING(MAO004_RawData, 3, 7) ,
					MAContractId = SUBSTRING(MAO004_RawData, 11, 5) ,
					TotalNumberOfRecords = 
							CASE
								WHEN ISNUMERIC(SUBSTRING(MAO004_RawData, 17, 18)) = 1 THEN CAST( SUBSTRING(MAO004_RawData, 17, 18)  AS INT)
								ELSE 0
							END
			FROM	
				dbo.MAO004_Raw		r
			INNER JOIN	
				dbo.MAO004_Header	h
				ON r.InboundFileName = h.InboundFileName
				AND r.LoadDateTime = h.LoadDateTime
			WHERE	SUBSTRING(MAO004_RawData, 1, 1) = '9'
					AND ProcessedFlag = 0;

		UPDATE
				dbo.MAO004_Raw
			SET	
				ProcessedFlag = '1'
			WHERE
				 SUBSTRING(MAO004_RawData, 1, 1) = '9'
			AND	 ProcessedFlag = 0


		END TRY	

		BEGIN CATCH
			SELECT	@ErrorNumber =  ERROR_NUMBER(),
					@ErrorSeverity = ERROR_SEVERITY(),
					@ErrorState = ERROR_STATE() ,
					@ErrorProcedure = ERROR_STATE() ,
					@ErrorLine = ERROR_LINE(),
					@ErrorMessage = ERROR_MESSAGE()

			--
			--	Print the error info so it will show up in any logs...
			--
			PRINT '--- Fatal Error ---'
			PRINT 'Error Number: ' + CAST(@ErrorNumber AS VARCHAR(10))
			PRINT 'Error Severity: ' + CAST(@ErrorSeverity AS VARCHAR(10))
			PRINT 'Error State: ' + CAST(@ErrorState AS VARCHAR(10))
			PRINT 'Error Procedure: ' + CAST(@ErrorProcedure AS VARCHAR(128))
			PRINT 'Error Line Number: ' + CAST(@ErrorLine AS VARCHAR(10))
			PRINT 'Error Message: ' + CAST(@ErrorMessage AS VARCHAR(4000))
			PRINT 'Error Return Code: ' + COALESCE(CAST(@SPReturnCode AS VARCHAR(10)), 'Unknown')

			IF @@TRANCOUNT > 0
				BEGIN
					ROLLBACK TRANSACTION
				END	
			RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState)
			RETURN
		END CATCH

		IF @@TRANCOUNT > 0
		BEGIN
			COMMIT	TRANSACTION
		END	

    END;

----------------------------------------------------------------
--
--		Unit Test
--
----------------------------------------------------------------
/*
BEGIN	TRANSACTION

	DECLARE @start DATETIME
	SET @start = GETDATE()

	EXEC dbo.spLoadMAO004_Phase2

	SELECT DATEDIFF(ms, @start, GETDATE()) AS 'Exec_ms'

ROLLBACK TRANSACTION
*/







GO
