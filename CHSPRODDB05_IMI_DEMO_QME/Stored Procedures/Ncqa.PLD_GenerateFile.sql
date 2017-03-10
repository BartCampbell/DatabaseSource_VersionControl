SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Kriz, Mike
-- Create date: 5/23/2012
-- Description:	Executes all of the potential processors for the given parameters.
-- =============================================
CREATE PROCEDURE [Ncqa].[PLD_GenerateFile]
(
	@DataRunID int,
	@IsExactProductLine bit = 0,
	@OutputResultset bit = 0,
	@OutputFileContent bit = 1,
	@OutputSQL bit = 0,
	@PayerID int = NULL,
	@PldFileID int,
	@PopulationID int,
	@ProductLineID int,
	
	--Required to generate the PLD Header--
	@CmsContractNumber char(5),
	@NcqaSubmissionID char(5),
	@OrganizationName char(60)
)
AS
BEGIN;

	SET NOCOUNT ON;

	IF EXISTS(SELECT TOP 1 1 FROM Ncqa.PLD_Files WHERE PldFileID = @PldFileID AND PldFileProcessID = 1)
	EXEC Ncqa.PLD_GenerateFilePerMember		@DataRunID = @DataRunID, @IsExactProductLine = @IsExactProductLine, @OutputResultset = @OutputResultset,
											@OutputFileContent = @OutputFileContent, @OutputSQL = @OutputSQL, @PayerID = @PayerID, @PldFileID = @PldFileID,
											@PopulationID = @PopulationID, @ProductLineID = @ProductLineID, @CmsContractNumber = @CmsContractNumber,
											@NcqaSubmissionID = @NcqaSubmissionID, @OrganizationName = @OrganizationName;
	
	IF EXISTS(SELECT TOP 1 1 FROM Ncqa.PLD_Files WHERE PldFileID = @PldFileID AND PldFileProcessID = 2)
	EXEC Ncqa.PLD_GenerateFilePerResultRow	@DataRunID = @DataRunID, @IsExactProductLine = @IsExactProductLine, @OutputResultset = @OutputResultset,
											@OutputFileContent = @OutputFileContent, @OutputSQL = @OutputSQL, @PayerID = @PayerID, @PldFileID = @PldFileID,
											@PopulationID = @PopulationID, @ProductLineID = @ProductLineID, @CmsContractNumber = @CmsContractNumber,
											@NcqaSubmissionID = @NcqaSubmissionID, @OrganizationName = @OrganizationName;
	
END;


GO
GRANT VIEW DEFINITION ON  [Ncqa].[PLD_GenerateFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_GenerateFile] TO [db_executer]
GO
GRANT EXECUTE ON  [Ncqa].[PLD_GenerateFile] TO [Processor]
GO
