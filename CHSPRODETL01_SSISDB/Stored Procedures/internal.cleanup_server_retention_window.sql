SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

            CREATE PROCEDURE [internal].[cleanup_server_retention_window]
            WITH EXECUTE AS 'AllSchemaOwner'
            AS
                SET NOCOUNT ON
                        
            DECLARE @enable_clean_operation bit
            DECLARE @retention_window_length int
            DECLARE @server_operation_encryption_level int

            DECLARE @caller_name nvarchar(256)
            DECLARE @caller_sid  varbinary(85)
            DECLARE @operation_id bigint

            EXECUTE AS CALLER
            SET @caller_name =  SUSER_NAME()
            SET @caller_sid =   SUSER_SID()
            REVERT

            -- delete operations based on the retension window size 
            BEGIN TRY
                SELECT @enable_clean_operation = CONVERT(bit, property_value) 
                FROM [catalog].[catalog_properties]
                WHERE property_name = 'OPERATION_CLEANUP_ENABLED'

                IF @enable_clean_operation = 1
                BEGIN
                    SELECT @retention_window_length = CONVERT(int,property_value)  
                        FROM [catalog].[catalog_properties]
                        WHERE property_name = 'RETENTION_WINDOW'


                    IF @retention_window_length <= 0 --a negative number is not valid
                    BEGIN
                        RAISERROR(27163,16,1,'RETENTION_WINDOW')
                    END

                    SELECT @server_operation_encryption_level = CONVERT(int,property_value)  
                        FROM [catalog].[catalog_properties]
                        WHERE property_name = 'SERVER_OPERATION_ENCRYPTION_LEVEL'

                    IF @server_operation_encryption_level NOT in (1,2)      --a number other than 1 and 2 is invalid
                    BEGIN
                        RAISERROR(27163,16,1,'SERVER_OPERATION_ENCRYPTION_LEVEL')
                    END
                    INSERT INTO [internal].[operations] (
                        [operation_type],  
                        [created_time], 
                        [object_type],
                        [object_id],
                        [object_name],
                        [status], 
                        [start_time],
                        [caller_sid], 
                        [caller_name]
                    )
                    VALUES (
                        2,
                        SYSDATETIMEOFFSET(),
                        NULL,                     -- No object type for this operation
                        NULL,                     -- The project_id is not set  
                        NULL,                     -- The object name is not set
                        1,      
                        SYSDATETIMEOFFSET(),
                        @caller_sid,            -- SID of the user 
                        @caller_name            -- Name of the database principal.
                    ) 
                    SET @operation_id = SCOPE_IDENTITY() 

                    DECLARE @temp_date datetime
                    DECLARE @rows_affected bigint
                    DECLARE @delete_batch_size int

                    -- every time, we would delete 1000 operations per batch
                    SET @delete_batch_size = 1000  
                    SET @rows_affected = @delete_batch_size

                    SET @temp_date = GETDATE() - @retention_window_length

                    IF @server_operation_encryption_level = 1
                    BEGIN
                        CREATE TABLE #deleted_ops (operation_id bigint, operation_type smallint)

                        DECLARE execution_cursor CURSOR LOCAL FOR 
                            SELECT operation_id FROM #deleted_ops 
                            WHERE operation_type = 200

                        DECLARE @execution_id bigint
                        DECLARE @sqlString              nvarchar(1024)
                        DECLARE @sqlString_cert         nvarchar(1024)
                        DECLARE @key_name               [internal].[adt_name]
                        DECLARE @certificate_name       [internal].[adt_name]

                        WHILE (@rows_affected = @delete_batch_size)
                        BEGIN
                            DELETE TOP (@delete_batch_size)
                            FROM [internal].[operations] 
                            OUTPUT DELETED.operation_id, DELETED.operation_type INTO #deleted_ops
                            WHERE ( [end_time] <= @temp_date
                            -- A special case when END_TIME is null, we will delete the records based on the created time 
                            OR ([end_time] IS NULL AND [status] = 1 AND [created_time] <= @temp_date ))

                            SET @rows_affected = @@ROWCOUNT

                            OPEN execution_cursor
                            FETCH NEXT FROM execution_cursor INTO @execution_id

                            WHILE @@FETCH_STATUS = 0
                            BEGIN
                                SET @key_name = 'MS_Enckey_Exec_'+CONVERT(varchar,@execution_id)
                                SET @certificate_name = 'MS_Cert_Exec_'+CONVERT(varchar,@execution_id)
                                SET @sqlString = 'DROP SYMMETRIC KEY '+ @key_name
                                SET @sqlString_cert = 'DROP CERTIFICATE '+ @certificate_name

                                BEGIN TRY
                                    EXECUTE sp_executesql @sqlString
                                    EXECUTE sp_executesql @sqlString_cert
                                END TRY

                                BEGIN CATCH
                                --do nothing, just save the cost of calling IF EXIST
                                END CATCH

                                FETCH NEXT FROM execution_cursor INTO @execution_id
                            END
                            CLOSE execution_cursor
                            TRUNCATE TABLE #deleted_ops
                        END
                        DROP TABLE #deleted_ops

                        DEALLOCATE execution_cursor
                    END
                    ELSE BEGIN
                        WHILE (@rows_affected = @delete_batch_size)
                        BEGIN
                            DELETE TOP (@delete_batch_size)
                            FROM [internal].[operations] 
                            WHERE ( [end_time] <= @temp_date
                            OR ([end_time] IS NULL AND [status] = 1 AND [created_time] <= @temp_date ))
                            SET @rows_affected = @@ROWCOUNT
                        END
                    END

                    UPDATE [internal].[operations]
                        SET [status] = 7,
                        [end_time] = SYSDATETIMEOFFSET()
                        WHERE [operation_id] = @operation_id
                END
            END TRY
            BEGIN CATCH
                -- If the cursor is still open, close it
                IF @server_operation_encryption_level = 1
                BEGIN
                    IF (CURSOR_STATUS('local', 'execution_cursor') = 1 
                        OR CURSOR_STATUS('local', 'execution_cursor') = 0)
                    BEGIN
                        CLOSE execution_cursor
                        DEALLOCATE execution_cursor
                    END
                END

                UPDATE [internal].[operations]
                    SET [status] = 4,
                    [end_time] = SYSDATETIMEOFFSET()
                    WHERE [operation_id] = @operation_id;
                THROW
            END CATCH

            RETURN 0
            
GO
GRANT EXECUTE ON  [internal].[cleanup_server_retention_window] TO [##MS_SSISServerCleanupJobUser##]
GO
