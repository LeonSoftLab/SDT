object mData: TmData
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 487
  Width = 486
  object Connection: TADOConnection
    CommandTimeout = 180
    ConnectionTimeout = 30
    CursorLocation = clUseServer
    IsolationLevel = ilReadCommitted
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 32
    Top = 8
  end
  object dsDatabases: TADODataSet
    Connection = Connection
    CommandText = 'EXEC sp_databases'
    CommandTimeout = 180
    Parameters = <>
    Left = 176
    Top = 8
  end
  object spDocuments: TADOStoredProc
    Connection = Connection
    ExecuteOptions = [eoExecuteNoRecords]
    CommandTimeout = 180
    ProcedureName = 'rplDocuments50;1'
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@op'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end>
    Left = 433
    Top = 59
  end
  object dsDocHeaders: TADODataSet
    Connection = Connection
    CommandTimeout = 180
    Parameters = <>
    Left = 337
    Top = 8
  end
  object dsDocRows: TADODataSet
    Connection = Connection
    CommandTimeout = 180
    Parameters = <>
    Left = 432
    Top = 8
  end
  object DataSource_refPriceType: TDataSource
    DataSet = ADOTable_refPriceType
    Left = 35
    Top = 145
  end
  object ADOTable_refPriceType: TADOTable
    Connection = ADOConn
    CursorType = ctStatic
    Filter = 'deleted='#39'False'#39
    Filtered = True
    LockType = ltReadOnly
    TableName = 'refPriceTypes'
    Left = 35
    Top = 190
  end
  object DataSource_refPriceList: TDataSource
    DataSet = ADOQuery_refPriceList
    Left = 135
    Top = 195
  end
  object ADOStoredProc_InsertPriceType: TADOStoredProc
    Connection = ADOConn
    ProcedureName = 'InsertPriceType;1'
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@Name'
        Attributes = [paNullable]
        DataType = ftWideString
        Size = 50
        Value = Null
      end
      item
        Name = '@idBasePriceType'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@idCurrency'
        Attributes = [paNullable]
        DataType = ftLargeint
        Precision = 19
        Value = Null
      end
      item
        Name = '@CrDate'
        Attributes = [paNullable]
        DataType = ftDateTime
        Value = Null
      end
      item
        Name = '@EndDate'
        Attributes = [paNullable]
        DataType = ftDateTime
        Value = Null
      end
      item
        Name = '@IsActive'
        Attributes = [paNullable]
        DataType = ftBoolean
        Value = Null
      end
      item
        Name = '@Code'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@deleted'
        Attributes = [paNullable]
        DataType = ftBoolean
        Value = Null
      end
      item
        Name = '@isedit'
        Attributes = [paNullable]
        DataType = ftWord
        Precision = 3
        Value = Null
      end
      item
        Name = '@ID'
        Attributes = [paNullable]
        DataType = ftLargeint
        Direction = pdInputOutput
        Precision = 19
        Value = Null
      end>
    Left = 135
    Top = 145
  end
  object ADOQuery_Info: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 255
    Top = 190
  end
  object DataSource_Info: TDataSource
    DataSet = ADOQuery_Info
    Left = 255
    Top = 145
  end
  object ADOQuery_refPriceList: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 135
    Top = 245
  end
  object ADODataSet_GetPriceFromOT: TADODataSet
    Connection = ADOConn
    CursorType = ctStatic
    CommandText = 'SELECT * FROM [dbo].[fnGetPriceFromOT]()'
    Parameters = <>
    Left = 255
    Top = 240
  end
  object ADODataSet_ExistsPriceType: TADODataSet
    Connection = ADOConn
    Parameters = <>
    Left = 255
    Top = 285
  end
  object ADOConn: TADOConnection
    CursorLocation = clUseServer
    DefaultDatabase = 'workdb4_7'
    IsolationLevel = ilReadCommitted
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 35
    Top = 245
  end
  object ADODataSet_GetInfo: TADODataSet
    Connection = ADOConn_Chicago
    Parameters = <>
    Left = 30
    Top = 420
  end
  object ADOStoredProc_ExpAllShedbyRoute: TADOStoredProc
    Connection = ADOConn_Chicago
    CursorLocation = clUseServer
    ProcedureName = 'exp_AllSched_byRoute;1'
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@offset'
        Attributes = [paNullable]
        DataType = ftInteger
        Precision = 10
        Value = Null
      end
      item
        Name = '@CodeRoutes'
        Attributes = [paNullable]
        DataType = ftWideString
        Size = 50
        Value = Null
      end
      item
        Name = '@Step1'
        Attributes = [paNullable]
        DataType = ftWideString
        Direction = pdInputOutput
        Size = 100
        Value = Null
      end
      item
        Name = '@Step2'
        Attributes = [paNullable]
        DataType = ftWideString
        Direction = pdInputOutput
        Size = 100
        Value = Null
      end
      item
        Name = '@Step3'
        Attributes = [paNullable]
        DataType = ftWideString
        Direction = pdInputOutput
        Size = 100
        Value = Null
      end>
    Left = 170
    Top = 420
  end
  object ADOConn_Chicago: TADOConnection
    CursorLocation = clUseServer
    DefaultDatabase = 'chicago'
    LoginPrompt = False
    Provider = 'SQLOLEDB.1'
    Left = 300
    Top = 420
  end
  object DataSource_Mustok_Type: TDataSource
    DataSet = ADOTable_Mustok_Type
    Left = 10
    Top = 295
  end
  object DataSource_Mustok: TDataSource
    DataSet = ADOTable_Mustok
    Left = 10
    Top = 335
  end
  object DataSource_Mustok_Row: TDataSource
    DataSet = ADOTable_Mustok_Row
    Left = 10
    Top = 380
  end
  object ADOTable_Mustok_Type: TADOTable
    Connection = ADOConn
    CursorType = ctStatic
    TableName = 'refMustokTypes'
    Left = 45
    Top = 295
  end
  object ADOTable_Mustok: TADOTable
    Connection = ADOConn
    CursorType = ctStatic
    IndexFieldNames = 'idType'
    MasterFields = 'id'
    MasterSource = DataSource_Mustok_Type
    TableName = 'refMustok'
    Left = 45
    Top = 335
  end
  object ADOTable_Mustok_Row: TADOTable
    Connection = ADOConn
    CursorType = ctStatic
    AfterScroll = ADOTable_Mustok_RowAfterScroll
    IndexFieldNames = 'idMustok'
    MasterFields = 'id'
    MasterSource = DataSource_Mustok
    TableName = 'refMustokRows'
    Left = 45
    Top = 380
  end
  object ADOQuery_Goods: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 180
    Top = 335
  end
  object ADOQuery_Goods_Type: TADOQuery
    Connection = ADOConn
    Parameters = <>
    Left = 215
    Top = 335
  end
  object DataSource_Goods: TDataSource
    DataSet = ADOQuery_Goods
    Left = 180
    Top = 365
  end
  object DataSource_Goods_Type: TDataSource
    DataSet = ADOQuery_Goods_Type
    Left = 215
    Top = 365
  end
end
