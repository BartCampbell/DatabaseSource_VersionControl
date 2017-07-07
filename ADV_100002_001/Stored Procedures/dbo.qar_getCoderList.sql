SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--qar_getCoderList 0,0,1,'','',0
CREATE PROCEDURE [dbo].[qar_getCoderList] 
    @Projects VARCHAR(1000) ,
    @ProjectGroup VARCHAR(1000) ,
    @User INT ,
    @txt_FROM SMALLDATETIME ,
    @txt_to SMALLDATETIME ,
    @date_range INT ,
    @location INT
AS
    BEGIN
        IF OBJECT_ID('tempdb.dbo.#tmpProject', 'U') IS NOT NULL
            DROP TABLE #tmpProject; 

	-- PROJECT SELECTION
        CREATE TABLE #tmpProject ( Project_PK INT );
        CREATE CLUSTERED INDEX idxProjectPK ON #tmpProject (Project_PK);
        IF @Projects = '0'
            BEGIN
                IF EXISTS ( SELECT  *
                            FROM    tblUser
                            WHERE   IsAdmin = 1
                                    AND User_PK = @User )	--For Admins
                    INSERT  INTO #tmpProject
                            ( Project_PK
                            )
                            SELECT DISTINCT
                                    Project_PK
                            FROM    tblProject P
                            WHERE   P.IsRetrospective = 1
                                    AND ( @ProjectGroup = 0
                                          OR ProjectGroup_PK = @ProjectGroup
                                        );
                ELSE
                    INSERT  INTO #tmpProject
                            ( Project_PK
                            )
                            SELECT DISTINCT
                                    P.Project_PK
                            FROM    tblProject P
                                    LEFT JOIN tblUserProject UP ON UP.Project_PK = P.Project_PK
                            WHERE   P.IsRetrospective = 1
                                    AND UP.User_PK = @User
                                    AND ( @ProjectGroup = 0
                                          OR ProjectGroup_PK = @ProjectGroup
                                        );
            END;
        ELSE
            EXEC ('INSERT INTO #tmpProject(Project_PK) SELECT Project_PK FROM tblProject WHERE Project_PK IN ('+@Projects+') AND ('+@ProjectGroup+'=0 OR ProjectGroup_PK='+@ProjectGroup+')');


        IF OBJECT_ID('tempdb.dbo.#UserSuspectsCoded', 'U') IS NOT NULL
            DROP TABLE #UserSuspectsCoded; 

        CREATE TABLE #UserSuspectsCoded
            (
              CodedData_PK BIGINT ,
              User_PK INT ,
              Coder VARCHAR(150) ,
              Suspect_PK BIGINT ,
              IsQA BIT ,
              QA_Date DATE ,
              IsCoded BIT ,
              Coded_Date DATE ,
              CONSTRAINT [PK_UserSuspectsTmp] PRIMARY KEY CLUSTERED ( CodedData_PK ASC )
            );

        INSERT  INTO #UserSuspectsCoded
                ( CodedData_PK ,
                  User_PK ,
                  Coder ,
                  Suspect_PK ,
                  IsQA ,
                  QA_Date ,
                  Coded_Date
                )
                SELECT  d.CodedData_PK ,
                        S.Coded_User_PK User_PK ,
                        U.Lastname + ', ' + U.Firstname + ' (' + U.Username + ')' Coder ,
                        S.Suspect_PK ,
                        S.IsQA ,
                        S.QA_Date ,
                        S.Coded_Date
                FROM    tblSuspect S WITH ( NOLOCK )
                        INNER JOIN #tmpProject P ON P.Project_PK = S.Project_PK
                        INNER JOIN tblUser U WITH ( NOLOCK ) ON U.User_PK = S.Coded_User_PK
                        INNER JOIN dbo.tblCodedData d ON d.Suspect_PK = S.Suspect_PK
                WHERE   S.IsCoded = 1
                        AND ( @location = 0
                              OR U.Location_PK = @location
                            )--335605
                        AND ( @date_range <> 2
                              OR d.Coded_Date BETWEEN @txt_FROM AND @txt_to
                            );

        CREATE NONCLUSTERED INDEX IDX_Suspect ON #UserSuspectsCoded (Suspect_PK ASC, User_PK, Coder, QA_Date) INCLUDE (IsQA);


        IF OBJECT_ID('tempdb.dbo.#ScannedData', 'U') IS NOT NULL
            DROP TABLE #ScannedData; 

        SELECT  S.Coded_User_PK ,
                COUNT(DISTINCT SD.ScannedData_PK) [Total Page Count]
        INTO    #ScannedData
        FROM    dbo.tblSuspect S
                INNER JOIN tblScannedData SD WITH ( NOLOCK ) ON S.Suspect_PK = SD.Suspect_PK
        WHERE   ( ISNULL(SD.is_deleted, 0) = 0 )
        GROUP BY S.Coded_User_PK;--1385

        SELECT  ROW_NUMBER() OVER ( ORDER BY S.Coder ) RowNumber ,
                S.User_PK ,
                S.Coder ,
                COUNT(DISTINCT S.Suspect_PK) [Coded Charts] ,
                SD.[Total Page Count] ,
                COUNT(DISTINCT CASE WHEN S.IsQA = 1 THEN S.Suspect_PK
                                    ELSE NULL
                               END) [QA Charts] ,
                CAST(ROUND(CAST(COUNT(DISTINCT CASE WHEN S.IsQA = 1 THEN S.Suspect_PK
                                                    ELSE NULL
                                               END) AS FLOAT) / CAST(COUNT(DISTINCT S.Suspect_PK) AS FLOAT) * 100, 2) AS VARCHAR) + ' %' [% QA Charts] ,
                COUNT(DISTINCT S.CodedData_PK) [Total Dx Coded] ,
                COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed = 1 THEN CDQ.CodedData_PK
                                    ELSE NULL
                               END) [Total Dx Confirmed] ,
                COUNT(DISTINCT CASE WHEN CDQ.IsChanged = 1 THEN CDQ.CodedData_PK
                                    ELSE NULL
                               END) [Total Dx Changed] ,
                COUNT(DISTINCT CASE WHEN CDQ.IsAdded = 1 THEN CDQ.CodedData_PK
                                    ELSE NULL
                               END) [Total Dx Added] ,
                COUNT(DISTINCT CASE WHEN CDQ.IsRemoved = 1 THEN CDQ.CodedData_PK
                                    ELSE NULL
                               END) [Total Dx Removed] ,
		--Total DX Confirmed/(Total DX Confirmed + Total DX Added + DX Changed + DX Removed)*100
                CASE WHEN COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed = 1 THEN CDQ.CodedData_PK
                                              ELSE NULL
                                         END) = 0 THEN ''
                     ELSE CAST(ROUND(CAST(COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed = 1 THEN CDQ.CodedData_PK
                                                              ELSE NULL
                                                         END) AS FLOAT) / ( CAST(COUNT(DISTINCT CASE WHEN CDQ.IsConfirmed = 1 THEN CDQ.CodedData_PK
                                                                                                     ELSE NULL
                                                                                                END) AS FLOAT)
                                                                            + CAST(COUNT(DISTINCT CASE WHEN CDQ.IsAdded = 1 THEN CDQ.CodedData_PK
                                                                                                       ELSE NULL
                                                                                                  END) AS FLOAT)
                                                                            + CAST(COUNT(DISTINCT CASE WHEN CDQ.IsChanged = 1 THEN CDQ.CodedData_PK
                                                                                                       ELSE NULL
                                                                                                  END) AS FLOAT)
                                                                            + CAST(COUNT(DISTINCT CASE WHEN CDQ.IsRemoved = 1 THEN CDQ.CodedData_PK
                                                                                                       ELSE NULL
                                                                                                  END) AS FLOAT) ) * 100, 0) AS VARCHAR) + ' %'
                END [QA Accuracy Rate]
        FROM    #UserSuspectsCoded S
                LEFT JOIN tblCodedDataQA CDQ WITH ( NOLOCK ) ON S.CodedData_PK = CDQ.CodedData_PK
                LEFT JOIN #ScannedData SD WITH ( NOLOCK ) ON S.User_PK = SD.Coded_User_PK
        WHERE   @date_range <> 1
                OR ( S.QA_Date BETWEEN @txt_FROM AND @txt_to )
                AND ( SD.Coded_User_PK IS NOT NULL
                      OR CDQ.IsRemoved = 1
                    )
        GROUP BY S.User_PK ,
                S.Coder ,
                SD.[Total Page Count];--1307

    END;
GO
