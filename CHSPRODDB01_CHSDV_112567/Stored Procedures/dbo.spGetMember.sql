SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- =============================================
-- Author:		Paul Johnson
-- Create date: 09/19/2016
-- Update 09/26/2016 Adding RecordEndDate filter PJ
-- Description:	Gets Members details from DV
-- =============================================
CREATE PROCEDURE [dbo].[spGetMember]
	-- Add the parameters for the stored procedure here
    @CCI VARCHAR(20) ,
    @LoadDate DATETIME
AS
    BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
        SET NOCOUNT ON;

    -- Insert statements for procedure here
	--   declare @CCI VARCHAR(20) ,    @LoadDate DATETIME
	
	--SET @cci=112547
	--SET @loaddate = '2016-08-01'

        TRUNCATE TABLE tmptbl;
        --CREATE TABLE #tmptbl
        --    (
        --      H_Member_RK [VARCHAR](50) NOT NULL ,
        --      [CentauriMemberID] [INT] NULL ,
        --      [SSN] [INT] NULL ,
        --      [LastName] [VARCHAR](100) NULL ,
        --      [FirstName] [VARCHAR](100) NULL ,
        --      [MiddleName] [INT] NULL ,
        --      [Prefix] [INT] NULL ,
        --      [Suffix] [INT] NULL ,
        --      [Gender] [VARCHAR](10) NULL ,
        --      [DOB] [DATETIME] NULL ,
        --      [RecordSource] [VARCHAR](100) NULL ,
        --      [ClientID] [VARCHAR](20) NULL ,
        --      [LoadDate] [DATETIME] NULL
        --    );

        INSERT  INTO tmptbl
                ( H_Member_RK ,
                  CentauriMemberID ,
                  [ClientID]
                )
                SELECT      DISTINCT
                        H_Member_RK ,
                        CAST(h.Member_BK AS INT) AS CentauriMemberID ,
                        @CCI
                FROM    [dbo].[H_Member] h;				

        UPDATE  tmptbl
        SET     LastName = s.LastName ,
                FirstName = s.FirstName ,
                Gender = s.Gender ,
                DOB = s.DOB ,
                RecordSource = s.RecordSource ,
                LoadDate = s.LoadDate
        FROM    tmptbl h
                INNER JOIN [dbo].[S_MemberDemo] s ON s.H_Member_RK = h.H_Member_RK AND s.RecordEndDate IS NULL
        WHERE   s.LoadDate > @LoadDate;
        
		DELETE FROM tmptbl WHERE (ISNULL(LastName,'')='' AND ISNULL(FirstName,'')='' AND ISNULL(Gender,'')='' AND ISNULL(DOB,'')='' )
		
		SELECT  *
        FROM    tmptbl;

        --DROP TABLE #tmptbl;

    END;


GO
