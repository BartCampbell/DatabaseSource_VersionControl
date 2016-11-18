SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- =============================================
-- Author:		Paul Johnson
-- Create date:	09/08/2016
-- Description:	merges the stage to dim for MemberChase 
-- Usage:			
--		  EXECUTE dbo.spAdvMergeMemberChase
-- =============================================
CREATE PROC [dbo].[spAdvMergeMemberChase]
AS
    DECLARE @CurrentDate DATETIME = GETDATE();

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN
    
	
        INSERT  INTO [fact].[MemberChase]
                ( [MemberID] ,
                  [ChaseID] ,
                  [PID] ,
                  [REN_Provider_Specialty] ,
                  [Segment_PK] ,
                  [ChartPriority] ,
                  [Ref_Number] ,
                  [RecordStartDate] ,
                  [RecordEndDate]
                )
                SELECT DISTINCT
                        m.MemberID ,
                        s.[ChaseID] ,
                        s.[PID] ,
                        s.[REN_Provider_Specialty] ,
                        s.[Segment_PK] ,
                        s.[ChartPriority] ,
                        s.[Ref_Number] ,
                        @CurrentDate ,
                        '2999-12-31 00:00:00.000'
                FROM    stage.MemberChase_ADV s
                        INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                        LEFT JOIN fact.MemberChase d ON d.MemberID = m.MemberID
                                                       AND ISNULL(d.[ChaseID],
                                                              0) = ISNULL(s.[ChaseID],
                                                              0)
                                                       AND ISNULL(d.[PID], '') = ISNULL(s.[PID],
                                                              '')
                                                       AND ISNULL(d.[REN_Provider_Specialty],
                                                              '') = ISNULL(s.[REN_Provider_Specialty],
                                                              '')
                                                       AND ISNULL(d.[Segment_PK],
                                                              0) = ISNULL(s.[Segment_PK],
                                                              0)
                                                       AND ISNULL(d.[ChartPriority],
                                                              '') = ISNULL(s.[ChartPriority],
                                                              '')
                                                       AND ISNULL(d.[Ref_Number],
                                                              '') = ISNULL(s.[Ref_Number],
                                                              '')
                WHERE   d.MemberChaseID IS NULL; 

		
		

        UPDATE  mc
        SET     mc.RecordEndDate = @CurrentDate
			  FROM    stage.MemberChase_ADV s
                INNER JOIN dim.Member m ON m.CentauriMemberID = s.CentauriMemberID
                INNER JOIN fact.MemberChase mc ON mc.MemberID = m.MemberID AND mc.ChaseID = s.ChaseID
        WHERE   (          ISNULL(mc.[PID], '') <> ISNULL(s.[PID], '')
                  OR ISNULL(mc.[REN_Provider_Specialty], '') <> ISNULL(s.[REN_Provider_Specialty],
                                                              '')
                  OR ISNULL(mc.[Segment_PK], 0) <> ISNULL(s.[Segment_PK], 0)
                  OR ISNULL(mc.[ChartPriority], '') <> ISNULL(s.[ChartPriority],
                                                              '')
                  OR ISNULL(mc.[Ref_Number], '') <> ISNULL(s.[Ref_Number], '')
                )
                AND mc.RecordEndDate = '2999-12-31 00:00:00.000';

    END;     



GO
