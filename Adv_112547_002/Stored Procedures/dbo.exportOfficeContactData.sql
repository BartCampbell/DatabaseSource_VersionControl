SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull diagnosis code description
-- =============================================
--	exportOfficeContactData '1-23-2015','1-30-2015'
--SELECT * FROM tmpProviderOfficeContactLog
CREATE PROCEDURE [dbo].[exportOfficeContactData]
	@Start AS Date,		--Give the date from where you want to start
	@End AS Date		--Give date+1 where you want want to end	
AS
BEGIN
	RETRY: -- Label RETRY
	BEGIN TRANSACTION
	BEGIN TRY
			SELECT DISTINCT Office_PK INTO #Office FROM tblContactNotesOffice WHERE LastUpdated_Date>=@Start AND LastUpdated_Date<@End
		
			DROP TABLE tmpProviderOfficeContactLog
			SELECT P.ProviderOffice_PK,P.Provider_ID,P.Lastname+IsNull(', '+P.Firstname,'') ProviderName
					,PO.EMR_Type,PO.Address,Z.City,Z.ZipCode,Z.State,COUNT(S.Suspect_PK) Charts
				INTO tmpProviderOfficeContactLog FROM tblSuspect S WITH (NOLOCK)
				INNER JOIN tblProvider P WITH (NOLOCK) ON P.Provider_PK = S.Provider_PK
				INNER JOIN tblProviderOffice PO WITH (NOLOCK) ON PO.ProviderOffice_PK = P.ProviderOffice_PK
				INNER JOIN #Office tOFF ON tOFF.Office_PK = PO.ProviderOffice_PK
				LEFT JOIN tblZipCode Z WITH (NOLOCK) ON Z.ZipCode_PK=PO.ZipCode_PK
			GROUP BY P.ProviderOffice_PK,P.Provider_ID,P.Lastname,P.Firstname,PO.EMR_Type,PO.Address,Z.City,Z.ZipCode,Z.State

			DECLARE @I AS SMALLINT = 1
			DECLARE @SQL AS VARCHAR(MAX)
			WHILE @I<26
			BEGIN
				SET @SQL = 'ALTER TABLE tmpProviderOfficeContactLog ADD [Note '+CAST(@I AS VARCHAR)+'] VARCHAR(100);ALTER TABLE tmpProviderOfficeContactLog ADD [Additional Note '+CAST(@I AS VARCHAR)+'] VARCHAR(100);';
				EXEC (@SQL)
				SET @I = @I + 1
			END

			DECLARE @OFFICE BIGINT
			DECLARE @Note VARCHAR(100)
			DECLARE @AdditionalNote VARCHAR(100)

			DECLARE @Office_Count INT = 0
			DECLARE @Office_Total int
			SELECT @Office_Total=COUNT(DISTINCT ProviderOffice_PK) FROM tmpProviderOfficeContactLog

			DECLARE OFF_CUR CURSOR FOR  
			SELECT DISTINCT ProviderOffice_PK FROM tmpProviderOfficeContactLog

			OPEN OFF_CUR  
			FETCH NEXT FROM OFF_CUR INTO @OFFICE   

			WHILE @@FETCH_STATUS = 0   
			BEGIN   
			---------------
					SET @Office_Count = @Office_Count +1
					PRINT '* * * * * * Processing Office '+ CAST(@Office_Count AS VARCHAR) + ' of  '+ CAST(@Office_Total AS VARCHAR)
					DECLARE CNO_CUR CURSOR FOR  
					SELECT TOP 25 CN.ContactNote_Text,CNO.ContactNoteText
						FROM tblContactNotesOffice CNO WITH (NOLOCK) INNER JOIN tblContactNote CN WITH (NOLOCK) ON CN.ContactNote_PK = CNO.ContactNote_PK
					WHERE CNO.Office_PK=@OFFICE ORDER BY CNO.LastUpdated_Date DESC

					SET @I = 1
					OPEN CNO_CUR
					FETCH NEXT FROM CNO_CUR INTO @Note,@AdditionalNote

					WHILE @@FETCH_STATUS = 0   
					BEGIN   
							SET @SQL = 'UPDATE tmpProviderOfficeContactLog SET [Note '+CAST(@I AS VARCHAR)+']='''+ @Note +''', [Additional Note '+CAST(@I AS VARCHAR)+']='''+ Replace(@AdditionalNote,'''','') +'''
								WHERE ProviderOffice_PK = ' + CAST(@OFFICE AS VARCHAR)
							EXEC (@SQL)
						   FETCH NEXT FROM CNO_CUR INTO @Note,@AdditionalNote    
						   SET @I = @I + 1
					END   

					CLOSE CNO_CUR   
					DEALLOCATE CNO_CUR
			---------------
					FETCH NEXT FROM OFF_CUR INTO @OFFICE     
			END   

			CLOSE OFF_CUR   
			DEALLOCATE OFF_CUR

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		SELECT 
		   ERROR_MESSAGE() AS ErrorMessage,
			ERROR_NUMBER() AS ErrorNumber		
		PRINT 'Rollback Transaction'
		ROLLBACK TRANSACTION
		IF ERROR_NUMBER() = 1205 -- Deadlock Error Number
		BEGIN
			WAITFOR DELAY '00:00:00.05' -- Wait for 5 ms
			GOTO RETRY -- Go to Label RETRY
		END
	END CATCH
END
GO
