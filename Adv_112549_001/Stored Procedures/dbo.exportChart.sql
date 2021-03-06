SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Sajid Ali
-- Create date: Mar-19-2014
-- Description:	RA Coder will use this sp to pull diagnosis code description
-- =============================================
/*
INSERT INTO tmpExportChases
SELECT *,GetDate() QuickRAPSDate FROM tmpExportAtenaProvMemb 

SELECT COUNT(*) Charts,QuickRAPSDate FROM tmpExportChases GROUP BY QuickRAPSDate ORDER BY QuickRAPSDate DESC 
*/
--	exportAtenaData
CREATE PROCEDURE [dbo].[exportChart]
AS
BEGIN
	RETRY: -- Label RETRY
	--BEGIN TRANSACTION
	BEGIN TRY
		--*********************************************************
		--CGS
		--BUILDS INITIAL LIST OF MEMBER AND PROVIDER DATA
		-----
		--*********************************************************
		IF OBJECT_ID('tempdb..#Chart') IS NOT NULL
			DROP TABLE #Chart

		CREATE TABLE #Chart
			(
				Member_PK				int
				,Suspect_PK				bigint
				,Provider_PK			int
				,[REN PROVIDER ID]		varchar(20)
				,[MEMBER ID]			varchar(22)
				,[Member Individual ID]	varchar(15)
				,ChaseID				varchar(50)
				,[PROVIDER TYPE]		varchar(50)
				,REN_TIN				varchar(20)
				,REN_PIN				varchar(20)
				,PID					varchar(20)
				,[CHART NAME]			varchar(100)
				,MemTempID				int IDENTITY(1,1) NOT NULL,
				CONSTRAINT [PK_MemTemp] PRIMARY KEY CLUSTERED 
					(
						MemTempID ASC
					)
					WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
			) ON [PRIMARY]
			
		INSERT INTO #Chart
			(
				Member_PK
				,Suspect_PK
				,Provider_PK
				,[REN PROVIDER ID]	
				,[MEMBER ID]
				,[Member Individual ID]	
				,ChaseID			
				,REN_TIN			
				,REN_PIN			
				,PID				
				,[CHART NAME]		
			)
		SELECT DISTINCT
				s.Member_PK
				,s.Suspect_PK
				,p.Provider_PK
				,pm.Provider_ID [REN PROVIDER ID]
				,m.Member_ID [MEMBER ID]
				,s.EDGEMemberID [Member Individual ID]
				,s.ChaseID
				,pm.TIN REN_TIN
				,pm.PIN REN_PIN
				,m.PID
				,SUBSTRING(s.ChaseID,2,5) +'_'+s.EDGEMemberID+'_MR_'+replace(substring(s.ChaseID,charindex(SUBSTRING(s.ChaseID,2,5),s.ChaseID),len(s.ChaseID)),'_','')+'_1of1' AS [CHART NAME]
		FROM	tblSuspect s
				INNER JOIN tblProvider p WITH (NOLOCK)
					ON s.Provider_PK = p.Provider_PK
				INNER JOIN tblProviderMaster pm WITH (NOLOCK)
					ON p.ProviderMaster_PK = pm.ProviderMaster_PK
				INNER JOIN tblMember m  WITH (NOLOCK)
					ON s.Member_PK = m.Member_PK
				INNER JOIN dbo.tblScannedData sd 
				ON sd.Suspect_PK = s.Suspect_PK
				--LEFT JOIN tmpExportChases t 
				--	ON s.Suspect_PK = t.Suspect_PK
		WHERE	
				--t.Suspect_PK IS NULL
				--AND
				s.IsScanned = 1 AND sd.is_deleted=0
				--AND 
				--s.Suspect_PK not IN
				--(SELECT DISTINCT sus.Suspect_PK FROM dbo.tblsuspect sus
				--	INNER JOIN attac_49532 bc ON bc.enrolleeid = sus.edgememberID
				--	UNION                    
				--	SELECT DISTINCT sus.Suspect_PK FROM dbo.tblsuspect sus
				--	INNER JOIN dbo.Attac_BCBSSample bc ON bc.enrolleeid = sus.edgememberID
					
				--	) --49532 Sample
			

		--*****************************************************************************
		TRUNCATE TABLE tmpExportChartStaging	
		

		INSERT INTO tmpExportChartStaging
			(
				 [Member ID]
				  ,[Member Individual ID]
				  ,[REN Provider ID]
				  ,[Member_PK]
				  ,[Suspect_PK]
				  ,[CHART NAME]
				  ,[ChaseID]
				  ,[InDummy]
				  ,[InNormal]
			)
		SELECT DISTINCT 
				[Member ID]
				,[Member Individual ID]
				,[REN Provider ID]
				,Member_PK
				,Suspect_PK
				,[CHART NAME]
				,ChaseID
				,NULL
				,NULL
		FROM	#Chart tf
	SELECT * FROM tmpExportChartStaging
--SELECT 'tmpExportChartStaging', COUNT(1) FROM tmpExportChartStaging

		DROP TABLE #Chart

		--COMMIT TRANSACTION
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
