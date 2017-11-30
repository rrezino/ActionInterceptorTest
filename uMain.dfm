object Form38: TForm38
  Left = 0
  Top = 0
  Caption = 'Form38'
  ClientHeight = 382
  ClientWidth = 505
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object btnTest: TButton
    Left = 8
    Top = 8
    Width = 145
    Height = 25
    Action = actShowMessage
    Caption = 'Show Message'
    TabOrder = 0
  end
  object btnStartInterception: TButton
    Left = 400
    Top = 72
    Width = 75
    Height = 25
    Caption = 'Start Logging'
    TabOrder = 1
  end
  object mmoLog: TMemo
    Left = 0
    Top = 103
    Width = 505
    Height = 279
    Align = alBottom
    TabOrder = 2
  end
  object btnStartLoggingWithObservable: TButton
    Left = 8
    Top = 64
    Width = 145
    Height = 25
    Caption = 'Start Observable'
    TabOrder = 3
    OnClick = btnStartLoggingWithObservableClick
  end
  object actMain: TActionList
    Left = 304
    Top = 16
    object actShowMessage: TAction
      Caption = 'actShowMessage'
      OnExecute = actShowMessageExecute
    end
  end
end
