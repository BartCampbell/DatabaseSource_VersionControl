SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--	cm_getRecentFiles 166,1,NULL
CREATE PROCEDURE [dbo].[cm_getRecentFiles] 
	@User smallint,
	@doNext tinyInt,
	@Date date
AS
BEGIN
		SELECT EQ.ExtractionQueue_PK,PDFname,
			COUNT(DISTINCT CASE WHEN EQAL.Suspect_PK<>0 AND IsInvoice=0 THEN EQAL.Suspect_PK ELSE NULL END) Charts,
			COUNT(DISTINCT CASE WHEN EQAL.Suspect_PK<>0 AND IsInvoice=1 THEN EQAL.Suspect_PK ELSE NULL END) Invoices,
			IsNull(MAX(EQAL.IsCNA),0) CNA,
			IsNull(MAX(EQAL.IsDuplicate),0) Duplicate,
			AssignedDate INTO #tmp FROM tblExtractionQueue EQ WITH (NOLOCK)
			LEFT JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
		WHERE AssignedUser_PK=@User AND (@Date IS NULL OR CAST(AssignedDate AS Date)=@Date)
		GROUP BY EQ.ExtractionQueue_PK,PDFname,AssignedDate
		Having @Date IS NOT NULL OR COUNT(DISTINCT EQAL.Suspect_PK)=0
		ORDER BY AssignedDate DESC
		
		IF (@Date IS NOT NULL)
		BEGIN
			SELECT * FROM #tmp ORDER BY AssignedDate DESC
			SELECT 10 Error
			Return;
		END

		IF EXISTS (SELECT * FROM #tmp)
		BEGIN
			SELECT * FROM #tmp ORDER BY AssignedDate DESC
			SELECT 1 Error
			Return;
		END

		if @doNext=1 
		BEGIN
			DECLARE @ExtractionQueueSource_PK AS TinyInt
			DECLARE @OfficeFaxOrID AS VARCHAR(10)
			DECLARE @Records AS SmallInt = 1000 
-----------Transaction Starts-------------------
			RETRY_NextAssign: -- Transaction RETRY
			BEGIN TRANSACTION
			BEGIN TRY
				IF (@User IN (0)) --Provider Portal
				BEGIN
					SET @ExtractionQueueSource_PK = 3
					SET @OfficeFaxOrID = 0
					SET @Records = 25
				END
				ELSE IF (@User IN (164,163,167,166,165)) --Mail-In
				BEGIN
					SET @ExtractionQueueSource_PK = 5
					SET @OfficeFaxOrID = 0
					SET @Records = 25
				END
				ELSE
				BEGIN
					SELECT TOP 1 @ExtractionQueueSource_PK=ExtractionQueueSource_PK, @OfficeFaxOrID=OfficeFaxOrID FROM tblExtractionQueue WHERE AssignedUser_PK IS NULL ORDER BY UploadDate ASC
					IF (@OfficeFaxOrID IS NULL)
					BEGIN
						SET @Records = 25
						SET @OfficeFaxOrID = '0'
					END
				END
				
				;
				with tbl as (
					SELECT TOP (@Records) * FROM tblExtractionQueue 
						WHERE AssignedUser_PK IS NULL AND ExtractionQueueSource_PK=@ExtractionQueueSource_PK AND IsNull(OfficeFaxOrID,'0')=@OfficeFaxOrID 
						ORDER BY UploadDate ASC
					)

				Update tbl SET AssignedUser_PK=@User, AssignedDate=GETDATE();

				COMMIT TRANSACTION
			END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
				BEGIN
					WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
					GOTO RETRY_NextAssign -- Go to Label RETRY
				END
			END CATCH
-----------Transaction Starts-------------------
		END
			
		SELECT EQ.ExtractionQueue_PK,PDFname,0 Charts,0 Invoices,0 CNA,0 Duplicate,AssignedDate FROM tblExtractionQueue EQ WITH (NOLOCK)
			LEFT JOIN tblExtractionQueueAttachLog EQAL WITH (NOLOCK) ON EQ.ExtractionQueue_PK = EQAL.ExtractionQueue_PK
		WHERE AssignedUser_PK=@User AND EQAL.ExtractionQueue_PK IS NULL
		ORDER BY AssignedDate DESC

		SELECT 20 Error
END
GO
