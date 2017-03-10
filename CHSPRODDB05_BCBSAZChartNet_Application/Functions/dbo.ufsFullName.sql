SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
--/*
CREATE FUNCTION [dbo].[ufsFullName]
(
 @vcFullName varchar(200),
 @cNameType char(1)
)
RETURNS varchar(50)
AS 
BEGIN
    DECLARE @vcReturnValue varchar(50)

    SET @vcFullName = RTRIM(@vcFullName)

	-- Validate parameters
    IF @vcFullName IS NULL OR
        @cNameType IS NULL OR
        @cNameType NOT IN ('L', 'F', 'M', 'S') OR
        CHARINDEX(',', @vcFullName) = 0 
        BEGIN
            SET @vcReturnValue = NULL
            GOTO DONE
        END

	-- Short circuit if possible
    IF LTRIM(RTRIM(@vcFullName)) IN ('', ',') 
        BEGIN
            SET @vcReturnValue = ''
            GOTO DONE
        END

    DECLARE @vcSurname varchar(100)
    DECLARE @vcGivenName varchar(100)
    DECLARE @vcSuffix varchar(100)
    DECLARE @tiSuffixStartPos tinyint
    DECLARE @tiSuffixLength tinyint
    DECLARE @tiMiddleNameStartPos tinyint

--Find Suffix - if any - and remove from full name string
    SET @tiSuffixStartPos = CHARINDEX(' JR.', @vcFullName)
    IF @tiSuffixStartPos <> 0 
        SET @tiSuffixLength = 3

    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' JR', @vcFullName)
            SET @tiSuffixLength = 2
        END

    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' SR.', @vcFullName)
            SET @tiSuffixLength = 3
        END

    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' SR', @vcFullName)
            SET @tiSuffixLength = 2
        END


    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' III', @vcFullName)
            SET @tiSuffixLength = 3
        END

    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' II', @vcFullName)
            SET @tiSuffixLength = 2
        END

    IF @tiSuffixStartPos = 0 
        BEGIN
            SET @tiSuffixStartPos = CHARINDEX(' IV', @vcFullName)
            SET @tiSuffixLength = 2
        END

    IF @tiSuffixStartPos > 0 
        BEGIN
            SET @vcSuffix = SUBSTRING(@vcFullName, @tiSuffixStartPos + 1,
                                      @tiSuffixLength)
            IF @cNameType = 'S' 
                BEGIN
                    IF @tiSuffixStartPos = 0 
                        SET @vcReturnValue = ''
                    ELSE 
                        SET @vcReturnValue = @vcSuffix 

                    GOTO DONE
                END
            IF LEN(@vcFullName) > @tiSuffixStartPos + @tiSuffixLength + 1 
                SET @vcFullName = LEFT(@vcFullName, @tiSuffixStartPos - 1) +
                    RIGHT(@vcFullName,
                          LEN(@vcFullName) - (@tiSuffixStartPos +
                                              @tiSuffixLength))
            ELSE 
                SET @vcFullName = LEFT(@vcFullName, @tiSuffixStartPos)
			
        END

--	PRINT @vcFullName

    IF @cNameType IN ('L') 
        BEGIN
            IF CHARINDEX(',', @vcFullName) > 1 
                BEGIN
                    SET @vcReturnValue = RTRIM(LEFT(@vcFullName,
                                                    CHARINDEX(',', @vcFullName) -
                                                    1))

                    GOTO DONE
                END
        END

    IF @cNameType IN ('F', 'M') 
        BEGIN
            IF LEN(@vcFullName) > (CHARINDEX(',', @vcFullName) + 1) 
                BEGIN

                    IF SUBSTRING(@vcFullname, CHARINDEX(',', @vcFullName) + 1,
                                 1) = ' ' 
                        SET @vcGivenName = SUBSTRING(@vcFullName,
                                                     CHARINDEX(',',
                                                              @vcFullName) + 2,
                                                     LEN(@vcFullName) -
                                                     (CHARINDEX(',',
                                                              @vcFullName) + 1))
                    IF SUBSTRING(@vcFullname, CHARINDEX(',', @vcFullName) + 1,
                                 1) <> ' ' 
                        SET @vcGivenName = SUBSTRING(@vcFullName,
                                                     CHARINDEX(',',
                                                              @vcFullName) + 1,
                                                     LEN(@vcFullName) -
                                                     (CHARINDEX(',',
                                                              @vcFullName)))

                    SET @tiMiddleNameStartPos = CHARINDEX(' ', @vcGivenName) +
                        1

                    IF @tiMiddleNameStartPos = 1 
                        SET @tiMiddleNameStartPos = 0

                    IF @cNameType = 'F' 
                        BEGIN
                            IF @tiMiddleNameStartPos = 0 
                                SET @vcReturnValue = @vcGivenName
                            ELSE 
                                SET @vcReturnValue = LEFT(@vcGivenName,
                                                          @tiMiddleNameStartPos -
                                                          2)

                            GOTO DONE
                        END

                    IF @cNameType = 'M' 
                        BEGIN
                            IF @tiMiddleNameStartPos = 0 
                                SET @vcReturnValue = ''
                            ELSE 
                                SET @vcReturnValue = SUBSTRING(@vcGivenName,
                                                              @tiMiddleNameStartPos,
                                                              LEN(@vcGivenName) -
                                                              @tiMiddleNameStartPos +
                                                              1)

                            GOTO DONE
                        END
                END
            ELSE 
                BEGIN
                    SET @vcReturnValue = ''
                    GOTO DONE
                END
        END

    DONE:
    RETURN @vcReturnValue


END
--SELECT @vcReturnValue
GO
