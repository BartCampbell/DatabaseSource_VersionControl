SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

/****************************************************************************************************************************************************
Purpose:				Create tables for test loading of BCBSA data files.
Depenedents:			

Usage

EXEC	[BCBSA].[spCreateRDSMTable] @Schema= N'BCBSA_GDIT2017',
		@destinationTable = N'20170202' 
		Enter Schema based on what year file format you are working with
		DestinationTable is sourceTable plus underscore plus whatever is entered as value for @destinationTable. 
		Only input the value that you want to append to the source table


Change Log:
----------------------------------------------------------------------------------------------------------------------------------------------------- 
2017-03-27	Corey Collins		- Create
2017-03-27	Michael Vlk			- Simplify
2017-03-27	Corey Collins		-Make Schema Dynamic
2017-03-31	Corey Collins		-Change ClaimInOutPatient to Claim
****************************************************************************************************************************************************/
CREATE PROC [BCBSA].[spCreateRDSMTable]
    (
    @DestinationTable varchar(255),@Schema varchar(50) 
    )
AS
--declare  @DestinationTable varchar(255)='Template',@Schema varchar(50)='BCBSA_GDIT2015'

    DECLARE @vSQL NVARCHAR(MAX);

	SET @vSQL = ''
    SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.Claim' + '_' + @DestinationTable + ';' + CHAR(10)  

	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.Enrollment' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.ExternalEvent' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.Group' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.Member' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.Provider' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.ProviderSpecialty' + '_' + @DestinationTable + ';' + CHAR(10) 
	SET @vSQL = @vSQL + 'DROP TABLE ' + @Schema +'.RxClaim' + '_' + @DestinationTable + ';' + CHAR(10) 
 

	PRINT @vsql

	SET @vSQL = ''
    SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.Claim' + '_' + @DestinationTable + ' FROM BCBSA.' + 'Claim_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.Enrollment' + '_' + @DestinationTable + ' FROM BCBSA.' + 'Enrollment_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.ExternalEvent' + '_' + @DestinationTable + ' FROM BCBSA.' + 'ExternalEvent_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.Group' + '_' + @DestinationTable + ' FROM BCBSA.' + 'Group_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.Member' + '_' + @DestinationTable + ' FROM BCBSA.' + 'Member_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.Provider' + '_' + @DestinationTable + ' FROM BCBSA.' + 'Provider_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.ProviderSpecialty' + '_' + @DestinationTable + ' FROM BCBSA.' + 'ProviderSpecialty_Template;' + CHAR(10)  
	SET @vSQL = @vSQL + 'SELECT * INTO '+@Schema+'.RxClaim' + '_' + @DestinationTable + ' FROM BCBSA.' + 'RxClaim_Template;' + CHAR(10)  

	PRINT @vsql
	--EXEC (@vsql) 


GO
