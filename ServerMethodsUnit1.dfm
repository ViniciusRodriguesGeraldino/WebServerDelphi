object ServerMethods1: TServerMethods1
  OldCreateOrder = False
  Height = 165
  Width = 287
  object FDConnection1: TFDConnection
    Params.Strings = (
      'Database=V:\SibraxFontes\WebServer\Win32\Debug\db'
      'DriverID=SQLite')
    LoginPrompt = False
    BeforeConnect = FDConnection1BeforeConnect
    Left = 40
    Top = 8
  end
  object tblEmp: TFDTable
    CachedUpdates = True
    IndexFieldNames = 'EMPRESA'
    Connection = FDConnection1
    UpdateOptions.UpdateTableName = 'EMPRESA'
    TableName = 'EMPRESA'
    Left = 24
    Top = 72
    object tblEmpEMPRESA: TIntegerField
      FieldName = 'EMPRESA'
      Origin = 'EMPRESA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
      Required = True
    end
    object tblEmpNOME: TStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Required = True
      Size = 255
    end
    object tblEmpENDERECO: TStringField
      FieldName = 'ENDERECO'
      Origin = 'ENDERECO'
      Size = 255
    end
    object tblEmpNUMERO: TStringField
      FieldName = 'NUMERO'
      Origin = 'NUMERO'
      Size = 10
    end
    object tblEmpBAIRRO: TStringField
      FieldName = 'BAIRRO'
      Origin = 'BAIRRO'
      Size = 255
    end
    object tblEmpCIDADE: TStringField
      FieldName = 'CIDADE'
      Origin = 'CIDADE'
      Size = 255
    end
    object tblEmpUF: TStringField
      FieldName = 'UF'
      Origin = 'UF'
      Size = 2
    end
    object tblEmpCOMPLEMENTO: TStringField
      FieldName = 'COMPLEMENTO'
      Origin = 'COMPLEMENTO'
      Size = 255
    end
    object tblEmpCNPJ: TStringField
      FieldName = 'CNPJ'
      Origin = 'CNPJ'
    end
    object tblEmpCEP: TStringField
      FieldName = 'CEP'
      Origin = 'CEP'
    end
    object tblEmpFONE: TStringField
      FieldName = 'FONE'
      Origin = 'FONE'
    end
    object tblEmpCELULAR: TStringField
      FieldName = 'CELULAR'
      Origin = 'CELULAR'
    end
    object tblEmpEMAIL: TStringField
      FieldName = 'EMAIL'
      Origin = 'EMAIL'
      Size = 255
    end
    object tblEmpPIX: TStringField
      FieldName = 'PIX'
      Origin = 'PIX'
      Size = 255
    end
  end
  object tblServicos: TFDTable
    CachedUpdates = True
    IndexFieldNames = 'EMPRESA;ID'
    Connection = FDConnection1
    UpdateOptions.UpdateTableName = 'SERVICOS'
    TableName = 'SERVICOS'
    Left = 144
    Top = 72
    object tblServicosEMPRESA: TIntegerField
      FieldName = 'EMPRESA'
      Origin = 'EMPRESA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object tblServicosID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object tblServicosCLIENTE_ID: TIntegerField
      FieldName = 'CLIENTE_ID'
      Origin = 'CLIENTE_ID'
    end
    object tblServicosVALOR: TFMTBCDField
      FieldName = 'VALOR'
      Origin = 'VALOR'
      Precision = 10
      Size = 5
    end
    object tblServicosNOME: TWideStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Size = 255
    end
    object tblServicosINICIO_SERVICO: TSQLTimeStampField
      FieldName = 'INICIO_SERVICO'
      Origin = 'INICIO_SERVICO'
    end
    object tblServicosFIM_SERVICO: TSQLTimeStampField
      FieldName = 'FIM_SERVICO'
      Origin = 'FIM_SERVICO'
    end
  end
  object tblClientes: TFDTable
    CachedUpdates = True
    IndexFieldNames = 'EMPRESA;ID'
    Connection = FDConnection1
    UpdateOptions.UpdateTableName = 'CLIENTES'
    TableName = 'CLIENTES'
    Left = 80
    Top = 72
    object tblClientesEMPRESA: TIntegerField
      FieldName = 'EMPRESA'
      Origin = 'EMPRESA'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object tblClientesID: TIntegerField
      FieldName = 'ID'
      Origin = 'ID'
      ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]
    end
    object tblClientesNOME: TStringField
      FieldName = 'NOME'
      Origin = 'NOME'
      Size = 255
    end
    object tblClientesCNPJ: TStringField
      FieldName = 'CNPJ'
      Origin = 'CNPJ'
    end
    object tblClientesFONE: TStringField
      FieldName = 'FONE'
      Origin = 'FONE'
    end
    object tblClientesVEICULO_MODELO: TStringField
      FieldName = 'VEICULO_MODELO'
      Origin = 'VEICULO_MODELO'
      Size = 255
    end
    object tblClientesPLACA_CARRO: TStringField
      FieldName = 'PLACA_CARRO'
      Origin = 'PLACA_CARRO'
      Size = 255
    end
  end
end
