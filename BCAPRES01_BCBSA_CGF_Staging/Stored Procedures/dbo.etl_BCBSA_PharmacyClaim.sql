SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*************************************************************************************
Procedure:	etl_BCBSA_PharmacyClaim
Author:		Tom Sharn
Copyright:	© 2015
Date:		2015.10.16
Purpose:	To load BCBSA Pharmacy data into Staging
Parameters:	@iLoadInstanceID	int.........IMIAdmin..ClientProcessInstance.LoadInstanceID
Depends On:	
Calls:		IMIAdmin..fxSetMetrics
			IMIAdmin..fxSetStatus
Called By:	dbo.IHDSBuildMaster
Returns:	None
Notes:		None
Process:	
Change Log:
3/30/2017 - Leon - Update for RDSM Schema

Test Script:	
		truncate table PharmacyClaim

		EXEC dbo.etl_BCBSA_PharmacyClaim 1

		SELECT DataSource, COUNT(*) 
			FROM dbo.PharmacyClaim 
			GROUP BY DataSource 

		SELECT count(*) FROM RDSM.Rxclaim

		SELECT TOP 10 * FROM RDSM.RxClaim

		SELECT TOP 10 * FROM RDSM.PROVIDER 

ToDo:		

*************************************************************************************/
--/*
CREATE PROC [dbo].[etl_BCBSA_PharmacyClaim]
(
	@iLoadInstanceID INT
)
AS

BEGIN TRY
--*/
--DECLARE @iLoadInstanceID INT = 1
/*************************************************************************************
        1.	Declare/initialize variables
*************************************************************************************/
DECLARE @iExpectedCnt INT
DECLARE @sysMe sysname
DECLARE @i INT

SET @sysMe = OBJECT_NAME(@@PROCID)

EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Started'

/*************************************************************************************
        2.  Delete temp tables if they already exist.
*************************************************************************************/
BEGIN 

	SELECT @i = COUNT(*)
		FROM PharmacyClaim

    TRUNCATE TABLE PharmacyClaim

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Delete',
        @i, 'etl_BCBSA_PharamcyClaim', 'RxClaim',
        @i

END 
		

/*************************************************************************************
        3.  Populate PharmacyClaim.
                Load dbo.PharmacyClaim
*************************************************************************************/
BEGIN
	--DELETE FROM dbo.PharmacyClaim_Rejected WHERE client = 'BCBSA'
	TRUNCATE TABLE dbo.PharmacyClaim_Rejected

	INSERT INTO dbo.PharmacyClaim_Rejected
	        (Client,
	         SrcTabDB,
	         SrcTabSchema,
	         SrcTabName,
	         RowID,
	         RowFileID,
	         LoadInstanceID,
	         LoadInstanceFileID,
	         RejecteReason
	        )
		SELECT 
			 Client = 'BCBSA',
	         SrcTabDB = 'BCBSA_RDSM',
	         SrcTabSchema = 'BCBSA_GDIT',
	         SrcTabName = 'RxClaim',
	         RowID = rx.RowID,
	         RowFileID = rx.RowFileID,
	         LoadInstanceID = rx.LoadInstanceID,
	         LoadInstanceFileID = rx.LoadInstanceFileID,
	         RejecteReason = CASE WHEN ISNULL(rx.NDCCode,'') = '' THEN 'No NDC Code' ELSE 'Member not in Member table' END
        FROM RDSM.RxClaim rx
			LEFT JOIN dbo.mpi_output_member mom
				ON mom.src_db_name = 'BCBSA_RDSM'
				AND mom.src_schema_name = 'BCBSA_GDIT'
				AND mom.src_table_name = 'RxClaim'
				AND mom.src_rowid = rx.RowID
			LEFT JOIN Member m
				ON mom.ihds_member_id= m.ihds_member_id
		WHERE m.ihds_member_id IS NULL OR ISNULL(rx.NDCCode,'') = ''

	--INSERT INTO dbo.PharmacyClaim_Rejected
	--        (Client,
	--         SrcTabDB,
	--         SrcTabSchema,
	--         SrcTabName,
	--         RowID,
	--         RowFileID,
	--         LoadInstanceID,
	--         LoadInstanceFileID,
	--         RejecteReason
	--        )
	--	SELECT top 10000
	--		 Client = 'BCBSA',
	--         SrcTabDB = 'BCBSA_RDSM',
	--         SrcTabSchema = 'BCBSA_GDIT',
	--         SrcTabName = 'RxClaim',
	--         RowID = rx.RowID,
	--         RowFileID = rx.RowFileID,
	--         LoadInstanceID = rx.LoadInstanceID,
	--         LoadInstanceFileID = rx.LoadInstanceFileID,
	--         RejecteReason = 'No NDC Code'
 --       FROM RDSM.RxClaim rx
	--		LEFT JOIN dbo.mpi_output_member mom
	--			ON mom.src_db_name = 'BCBSA_RDSM'
	--			AND mom.src_schema_name = 'BCBSA_GDIT'
	--			AND mom.src_table_name = 'RxClaim'
	--			AND mom.src_rowid = rx.RowID
	--	WHERE ISNULL(rx.NDCCode,'') = ''

	--	Insert records 
    INSERT INTO dbo.PharmacyClaim
            (
				ClaimNumber,
				ClaimSequenceNumber,
				ClaimStatus,
				Client,
				CustomerMemberID,
				DataSource,
				DateDispensed,
				DateOrdered,
				DateRowCreated,
				DaysSupply,
				DrugTherapeuticClass,
				ihds_member_id,
				LoadInstanceFileID,
				RowFileID,
				MemberAge,
				MemberID,
				NDC,
				Quantity,
				--QuantityDispensed_Submitted,
				--QuantityPaid,
				RefillNumber,
				RowID,
				QuantityDispensed,
				CustomerProviderID,
				CustomerPrescribingID,
				SupplementalDataCategory,
				SupplementalDataFlag				
            )
        SELECT
			ClaimNumber = rx.ClaimNumber,
			ClaimSequenceNumber = rx.ClaimLineNumber,
			ClaimStatus = rx.Denied, --TODO: Needs review
			Client = 'BCBSA',
			CustomerMemberID = rx.MemberID,
			DataSource = 'BCBSA_GDIT.RxClaim',
			DateDispensed = CASE WHEN CONVERT(DATETIME, rx.DispenseDate) >= '19000101' THEN rx.DispenseDate END,
			DateOrdered = CASE WHEN CONVERT(DATETIME, rx.PrescribedDate) >= '19000101' THEN rx.PrescribedDate END,
			DateRowCreated = CONVERT(VARCHAR(8), GETDATE(), 112),
			DaysSupply = CONVERT(NUMERIC(6,0),rx.SupplyDays),
			DrugTherapeuticClass = rx.ClassCategoryCode, --TODO: Needs review
			ihds_member_id = mom.ihds_member_id,
			LoadInstanceFileID = rx.LoadInstanceFileID,
			RowFileID = rx.RowFileID,
			MemberAge = dbo.GetAgeAsOf(m.DateOfBirth,rx.DispenseDate),
			MemberID = m.MemberID,
			NDC = rx.NDCCode,
			Quantity =  FLOOR(rx.QuantityDispensed),-- QME field is Int
			--QuantityDispensed_Submitted = CONVERT(NUMERIC(11,3),rx.QuantityDispensed),
			--QuantityPaid = CONVERT(NUMERIC(11,3),rx.QuantityDispensed),
			RefillNumber = CONVERT(NUMERIC(6,0),rx.RefillCount),
			RowID = rx.RowID,
			QuantityDispensed = CONVERT(DECIMAL(18,6),rx.QuantityDispensed), -- QME field is Decimal(18,6)
			CustomerProviderID = rx.DispensingProv,
			CustomerPrescribingID = rx.PrescribingProv,
			SupplementalDataCategory = rx.SupplementalDataSource,
			SupplementalDataFlag = CASE WHEN ISNULL(SupplementalDataSource,'') <> '' THEN 'Y' ELSE 'N' END
		--select count(*)
        FROM RDSM.RxClaim rx
			LEFT JOIN dbo.PharmacyClaim_Rejected rej
				ON rej.SrcTabDB = 'BCBSA_RDSM'
				AND rej.SrcTabSchema = 'BCBSA_GDIT'
				AND rej.SrcTabName = 'RxClaim'
				AND rej.RowID = rx.RowID 
			INNER JOIN dbo.mpi_output_member mom
				ON mom.src_db_name = 'BCBSA_RDSM'
				AND mom.src_schema_name = 'BCBSA_GDIT'
				AND mom.src_table_name = 'RxClaim'
				AND mom.src_rowid = rx.RowID
            INNER JOIN dbo.Member m
                ON mom.ihds_member_id = m.ihds_member_id
		WHERE rej.RowID IS NULL

    EXECUTE IMIAdmin.dbo.fxSetMetrics @iLoadInstanceID, 'Records Inserted', @@RowCOUNT,
        'etl_BCBSA_PharamcyClaim',
        'PharmacyClaim from BCBSA_GDIT.RxClaim', @@RowCOUNT


END 


/*************************************************************************************
        14.  Delete temp tables if they already exist.
*************************************************************************************/
IF OBJECT_ID('tempdb..#rx') IS NOT NULL
    DROP TABLE #rx

EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Completed'


--/*
END TRY

BEGIN CATCH
        DECLARE @iErrorLine		int,
                @iErrorNumber		int,
                @iErrorSeverity		int,
                @iErrorState		int,
                @nvcErrorMessage	nvarchar( 2048 ), 
                @nvcErrorProcedure	nvarchar( 126 )

        -- capture error info so we can fail it up the line
        SELECT	@iErrorLine = ERROR_LINE(),
                @iErrorNumber = ERROR_NUMBER(),
                @iErrorSeverity = ERROR_SEVERITY(),
                @iErrorState = ERROR_STATE(),
                @nvcErrorMessage = ERROR_MESSAGE(),
                @nvcErrorProcedure = ERROR_PROCEDURE()

        INSERT INTO IMIAdmin..ErrorLog( ErrorLine, ErrorMessage, ErrorNumber, ErrorProcedure, ErrorSeverity,
                ErrorState, ErrorTime, InstanceID, UserName )
        SELECT	@iErrorLine, @nvcErrorMessage, @iErrorNumber, @nvcErrorProcedure, @iErrorSeverity,
                @iErrorState, GETDATE(), InstanceID, SUSER_SNAME()
        FROM	IMIAdmin..ClientProcessInstance
        WHERE	LoadInstanceID = @iLoadInstanceID

        PRINT	'Error Procedure: ' + @sysMe
        PRINT	'Error Line:      ' + CAST( @iErrorLine AS varchar( 12 ))
        PRINT	'Error Number:    ' + CAST( @iErrorNumber AS varchar( 12 ))
        PRINT	'Error Message:   ' + @nvcErrorMessage
        PRINT	'Error Severity:  ' + CAST( @iErrorSeverity AS varchar( 12 ))
        PRINT	'Error State:     ' + CAST( @iErrorState AS varchar( 12 ))

        EXECUTE IMIAdmin..fxSetStatus @iLoadInstanceID, @sysMe, 'Failed'

        RAISERROR( @nvcErrorMessage, @iErrorSeverity, @iErrorState );
END CATCH

--*/	


GO
