----- Prerequesites
----- If you have not created a table to hold the results from your scripts...
/*
        BEGIN
            CREATE TABLE ScriptMonitor
        (
            id INT NOT NULL
                IDENTITY(1, 1)
                PRIMARY KEY
        ,ScriptName VARCHAR(50)
,ScriptStart DATETIME
,ScriptEnd DATETIME
        ,Query VARCHAR(MAX)
        ,QueryStart DATETIME
        ,QueryEnd DATETIME NULL
        );
        END;
*/

CREATE PROCEDURE usp_scriptmonitor
  @SessionID         INT          -- The session number you are running your script in. ex('56')
  @ScriptName        nvarchar(50) -- Whatever you call this specific script so that you can look it up later. ex('My Script')
  @Delay             nvarchar(10) -- How often you want to check whether or not the script is running a new query. ex('00:00:01')

DECLARE @ScriptStart datetime = getdate() ,
  @CurrentQuery      nvarchar(max) ,
  @PreviousQuery     nvarchar(max) ='' ,
  @PreviousID        int

----- Check for the session's existence, and do this while the session exists at the delay set in the declaration.
WHILE EXISTS
(
       SELECT 1
       FROM   sys.dm_exec_requests
       WHERE  session_id = @SessionID)
BEGIN

  ----- Find the current query being run within the script.

  SELECT      @CurrentQuery = substring (qt.text, (er.statement_start_offset/2) + 1, ((
              CASE
                          WHEN er.statement_end_offset = -1 THEN len(CONVERT(nvarchar(max), qt.text)) * 2
                          ELSE er.statement_end_offset
              END - er.statement_start_offset)/2) + 1)
  FROM        sys.dm_exec_requests er
  INNER JOIN  sys.sysprocesses sp
  ON          er.session_id = sp.spid
  INNER JOIN  sys.databases sd
  ON          er.database_id = sd.database_id
  CROSS apply sys.dm_exec_sql_text(er.sql_handle)AS qt
  WHERE       session_id = @SessionID
  AND         session_id NOT IN (@@SPID)
  GROUP BY    substring (qt.text, (er.statement_start_offset/2) + 1, ((
              CASE
                          WHEN er.statement_end_offset = -1 THEN len(CONVERT(nvarchar(max), qt.text)) * 2
                          ELSE er.statement_end_offset
              END - er.statement_start_offset)/2) + 1) ￼

  ----- If there was a different query running the last time this loop ran, do this....

  IF @PreviousQuery <> @CurrentQuery
  BEGIN

    ----- Set the previous query's end time to the current time if there WAS a previous query.

    IF @PreviousID IS NOT NULL
    UPDATE scriptmonitor
    SET    queryend = getdate()
    WHERE  id = @PreviousID

    ----- Insert the current query into the ScriptMonitor table.

    INSERT INTO scriptmonitor
                (
                            scriptname,
                            scriptstart,
                            query,
                            querystart
                )
                VALUES
                (
                            @ScriptName,
                            @ScriptStart,
                            @CurrentQuery,
                            getdate()
                )

		----- Get the id of the newly inserted query.

    SELECT @PreviousID=scope_identity()
  END

  ----- Set the PreviousQuery to be the CurrentQuery
	
  SET @PreviousQuery=@CurrentQuery WAITFOR delay @Delay;
end
IF @PreviousID IS NOT NULL
UPDATE scriptmonitor
SET    queryend = getdate()
WHERE  id = @PreviousID
UPDATE scriptmonitor
SET    scriptend=getdate()
WHERE  scriptstart=@ScriptStart
