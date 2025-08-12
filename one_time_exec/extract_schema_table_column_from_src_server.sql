-- Run this query in the source SQL Server database to extract
-- schemas, tables and columns, used to populate 
-- file 'configuration.xlsx'
SELECT
  ''                   AS [Key-vault URL]
  , ''                 AS [Key-vault Username]
  , ''                 AS [Key-vault Password]
  , @@SERVERNAME       AS [Server]
  , DB_NAME()          AS [Database]
  , C.TABLE_SCHEMA     AS [Schema]
  , C.TABLE_NAME       AS [Table]
  , 'EI'               AS [Load Type]
  , 'Daily'            AS [Frequency]
  , C.ORDINAL_POSITION AS [Sequence]
  , 'Now'              AS [Extraction Timeframe]
  , ''                 AS [FROM]
  , ''                 AS [WHERE]
  , CASE
    WHEN PK.COLUMN_NAME IS NOT NULL THEN 'Oui'
                                    ELSE 'Non'
  END                  AS [Is PK?]
  , ''                 AS [Prefix SELECT]
  , C.COLUMN_NAME      AS [Column]
  , 'Yes'              AS [Is Included?]
  -- Cast SQL Server data types to Delta data types
  , CASE
    WHEN C.DATA_TYPE IN('uniqueidentifier', 'text', 'ntext', 'xml'
      , 'hierarchyid', 'geography', 'varchar', 'nvarchar'
      , 'char', 'nchar') THEN 'String'
    WHEN C.DATA_TYPE IN ('decimal', 'numeric', 'smallmoney', 'money') THEN 'Decimal'
    WHEN C.DATA_TYPE IN ('binary', 'varbinary', 'image') THEN 'Binary'
    WHEN C.DATA_TYPE = 'bit' THEN 'Boolean'
    WHEN C.DATA_TYPE = 'float' THEN 'Double'
	  WHEN C.DATA_TYPE = 'real' THEN 'Real'
    WHEN C.DATA_TYPE = 'tinyint' THEN 'Byte'
    WHEN C.DATA_TYPE = 'date' THEN 'Date'
    WHEN C.DATA_TYPE = 'int' THEN 'Integer'
    WHEN C.DATA_TYPE = 'bigint' THEN 'Long'
    WHEN C.DATA_TYPE = 'smallint' THEN 'Short'
    WHEN C.DATA_TYPE IN ('smalldatetime', 'datetime', 'datetime2'
      , 'time', 'datetimeoffset') THEN 'Timestamp'
  END                  AS [Type de donn�es]
FROM
  INFORMATION_SCHEMA.COLUMNS          AS C
  LEFT JOIN INFORMATION_SCHEMA.TABLES AS T ON  C.TABLE_CATALOG = T.TABLE_CATALOG
                                           AND C.TABLE_SCHEMA  = T.TABLE_SCHEMA
                                           AND C.TABLE_NAME    = T.TABLE_NAME
  LEFT JOIN
  (
    SELECT ku.TABLE_CATALOG,ku.TABLE_SCHEMA,ku.TABLE_NAME,ku.COLUMN_NAME
    FROM
      INFORMATION_SCHEMA.TABLE_CONSTRAINTS     AS TC
      JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE AS KU ON  TC.CONSTRAINT_TYPE = 'PRIMARY KEY'
                                                     AND TC.CONSTRAINT_NAME = KU.CONSTRAINT_NAME
  )                                            AS PK ON  C.TABLE_CATALOG    = PK.TABLE_CATALOG
                                                     AND C.TABLE_SCHEMA     = PK.TABLE_SCHEMA
                                                     AND C.TABLE_NAME       = PK.TABLE_NAME
                                                     AND C.COLUMN_NAME      = PK.COLUMN_NAME
WHERE
  T.TABLE_TYPE       = 'BASE TABLE'
  AND C.TABLE_SCHEMA != 'dbo'
  -- add filters here
ORDER BY
  C.TABLE_SCHEMA
  , C.TABLE_NAME
  , C.ORDINAL_POSITION;