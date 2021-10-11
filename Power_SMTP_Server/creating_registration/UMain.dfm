object Activation_Bt: TActivation_Bt
  Left = 227
  Top = 127
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Enregistrement'
  ClientHeight = 106
  ClientWidth = 253
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 120
  TextHeight = 16
  object User_Lb: TLabel
    Left = 8
    Top = 17
    Width = 36
    Height = 16
    Caption = 'Login:'
  end
  object Password_Lb: TLabel
    Left = 8
    Top = 48
    Width = 63
    Height = 16
    Caption = 'Password:'
  end
  object User_Ed: TEdit
    Left = 56
    Top = 8
    Width = 185
    Height = 24
    TabOrder = 0
  end
  object Password_Ed: TEdit
    Left = 80
    Top = 40
    Width = 161
    Height = 24
    TabOrder = 1
  end
  object Button1: TButton
    Left = 8
    Top = 72
    Width = 233
    Height = 25
    Caption = 'Create activation'
    TabOrder = 2
    OnClick = Button1Click
  end
end
