object Form1: TForm1
  Left = 229
  Top = 126
  Width = 576
  Height = 406
  BorderIcons = [biSystemMenu]
  Caption = 'FireWall XP'
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  DesignSize = (
    568
    378)
  PixelsPerInch = 120
  TextHeight = 16
  object Button1: TButton
    Left = 8
    Top = 40
    Width = 553
    Height = 25
    Anchors = [akLeft, akTop, akRight]
    Caption = 'Add/Update rule ...'
    TabOrder = 0
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 8
    Top = 72
    Width = 137
    Height = 25
    Caption = 'Active (deblock)'
    TabOrder = 1
  end
  object Button2: TButton
    Left = 456
    Top = 72
    Width = 105
    Height = 25
    Anchors = [akTop, akRight]
    Caption = 'Verify'
    TabOrder = 2
    OnClick = Button2Click
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 359
    Width = 568
    Height = 19
    Panels = <
      item
        Width = 300
      end>
  end
  object Edit1: TEdit
    Left = 8
    Top = 8
    Width = 81
    Height = 24
    Hint = 'Nom de la regle'
    TabOrder = 4
    OnChange = Edit1Change
  end
  object Edit2: TEdit
    Left = 96
    Top = 8
    Width = 465
    Height = 24
    Hint = 'Chemin complet'
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 5
  end
  object PC: TPageControl
    Left = 8
    Top = 104
    Width = 553
    Height = 249
    ActivePage = TabSheet1
    TabOrder = 6
    object TabSheet1: TTabSheet
      Caption = 'Exceptions Applications'
      object LB: TListBox
        Left = 0
        Top = 0
        Width = 545
        Height = 218
        Align = alClient
        ItemHeight = 16
        TabOrder = 0
      end
    end
    object TabSheet2: TTabSheet
      Caption = 'Exceptions Services'
      ImageIndex = 1
      object LB1: TListBox
        Left = 0
        Top = 0
        Width = 545
        Height = 218
        Align = alClient
        ItemHeight = 16
        TabOrder = 0
      end
    end
    object TabSheet3: TTabSheet
      Caption = 'Exceptions Ports'
      ImageIndex = 2
      object LB2: TListBox
        Left = 0
        Top = 0
        Width = 545
        Height = 218
        Align = alClient
        ItemHeight = 16
        TabOrder = 0
      end
    end
  end
end
