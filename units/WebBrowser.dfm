object WebBrowserWin: TWebBrowserWin
  Left = 673
  Top = 170
  ClientHeight = 476
  ClientWidth = 632
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlTop: TPanel
    Left = 0
    Top = 0
    Width = 632
    Height = 32
    Align = alTop
    TabOrder = 0
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 438
      Height = 30
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      DesignSize = (
        438
        30)
      object btnSize1: TButton
        Left = 252
        Top = 1
        Width = 61
        Height = 26
        Hint = 'Window size'
        Anchors = [akTop, akRight]
        Caption = '640x480'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        OnClick = btnSize1Click
      end
      object btnSize2: TButton
        Left = 314
        Top = 1
        Width = 61
        Height = 26
        Hint = 'Window size'
        Anchors = [akTop, akRight]
        Caption = '800x600'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 1
        OnClick = btnSize2Click
      end
      object btnSize3: TButton
        Left = 374
        Top = 1
        Width = 61
        Height = 26
        Hint = 'Window size'
        Anchors = [akTop, akRight]
        Caption = '1024x768'
        ParentShowHint = False
        ShowHint = True
        TabOrder = 2
        OnClick = btnSize3Click
      end
      object edURL: TEdit
        Left = 5
        Top = 4
        Width = 246
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 3
        OnKeyDown = edURLKeyDown
        OnKeyPress = edURLKeyPress
      end
    end
    object Panel2: TPanel
      Left = 439
      Top = 1
      Width = 192
      Height = 30
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object ToolBar1: TToolBar
        Left = 0
        Top = 0
        Width = 192
        Height = 29
        Anchors = [akTop, akRight]
        ButtonHeight = 26
        ButtonWidth = 26
        Images = ImageList
        ParentShowHint = False
        ShowHint = True
        TabOrder = 0
        object ToolButton1: TToolButton
          Left = 0
          Top = 0
          Action = ActionRefresh
        end
        object ToolButton2: TToolButton
          Left = 26
          Top = 0
          Action = ActionBack
        end
        object ToolButton3: TToolButton
          Left = 52
          Top = 0
          Action = ActionHome
        end
        object ToolButton4: TToolButton
          Left = 78
          Top = 0
          Action = ActionFwd
        end
        object ToolButton7: TToolButton
          Left = 104
          Top = 0
          Width = 8
          Caption = 'ToolButton7'
          ImageIndex = 2
          Style = tbsSeparator
        end
        object ToolButton5: TToolButton
          Left = 112
          Top = 0
          Action = ActionEdit
        end
        object tbOk: TToolButton
          Left = 138
          Top = 0
          Action = ActionExit
          ImageIndex = 6
        end
        object ToolButton6: TToolButton
          Left = 164
          Top = 0
          Action = ActionCancel
        end
      end
    end
  end
  object ActionList: TActionList
    Left = 520
    Top = 85
    object ActionEdit: TAction
      Category = 'Global'
      Hint = 'Edit source txt'
      ImageIndex = 0
      ShortCut = 121
      OnExecute = ActionEditExecute
    end
    object ActionRefresh: TAction
      Category = 'Navigation'
      Caption = 'ActionRefresh'
      Hint = 'Reload'
      ImageIndex = 2
      OnExecute = ActionRefreshExecute
    end
    object ActionHome: TAction
      Category = 'Navigation'
      Caption = 'ActionHome'
      Hint = 'Home'
      ImageIndex = 3
      OnExecute = ActionHomeExecute
    end
    object ActionBack: TAction
      Category = 'Navigation'
      Caption = 'ActionBack'
      Hint = 'Previous page'
      ImageIndex = 4
      OnExecute = ActionBackExecute
    end
    object ActionFwd: TAction
      Category = 'Navigation'
      Caption = 'ActionFwd'
      Hint = 'Next page'
      ImageIndex = 5
      OnExecute = ActionFwdExecute
    end
    object ActionCancel: TAction
      Category = 'Global'
      Caption = 'Cancel'
      Hint = 'Close'
      ImageIndex = 1
      OnExecute = ActionCancelExecute
    end
    object ActionExit: TAction
      Category = 'Global'
      Caption = 'Exit'
      Hint = 'OK and close'
      OnExecute = ActionExitExecute
    end
  end
  object ImageList: TImageList
    Left = 570
    Top = 85
    Bitmap = {
      494C010107000900200010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000002000000001002000000000000020
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008000
      0000008000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000800000000080
      0000008000000080000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000010100C0010100C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000010100C001010
      0C00000000000000000000000000000000000000000080000000008000000080
      0000008000000080000000800000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000001010
      0C0010FBF70010100C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000010100C0010FB
      F70010100C000000000000000000000000008000000000800000008000000080
      000000FF00000080000000800000008000008000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000101010000D4
      FF0000D4FF0010100C0010100C0010100C0010100C0010100C00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000010100C0010100C0010100C0010100C0010100C0000D4
      FF0000D4FF0001010100000000000000000000800000008000000080000000FF
      00000000000000FF000000800000008000000080000080000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000101010000A9FF0000A9
      FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9
      FF0000A9FF0000A9FF0000A9FF00000000000000000000A9FF0000A9FF0000A9
      FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9FF0000A9
      FF0000A9FF0000A9FF00010101000000000000FF00000080000000FF00000000
      0000000000000000000000FF0000008000000080000000800000800000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000010100C001989F300007FFF00007F
      FF00007FFF00007FFF00007FFF00007FFF00007FFF00007FFF00007FFF001989
      F300007FFF00007FFF00007FFF000000000000000000007FFF00007FFF00007F
      FF001989F300007FFF00007FFF00007FFF00007FFF00007FFF00007FFF00007F
      FF00007FFF00007FFF001989F30010100C000000000000FF0000000000000000
      000000000000000000000000000000FF00000080000000800000008000008000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000010100C001C65F1000054
      FF000054FF000054FF000054FF000054FF000054FF000054FF001C65F1001C65
      F1000054FF000054FF000054FF0000000000000000000054FF000054FF000054
      FF001C65F1001C65F1000054FF000054FF000054FF000054FF000054FF000054
      FF000054FF001C65F10010100C00000000000000000000000000000000000000
      00000000000000000000000000000000000000FF000000800000008000000080
      0000800000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000010100C001F43
      F000002AFF0010100C0010100C0010100C0010100C0010100C0010100C000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000010100C0010100C0010100C0010100C0010100C0010100C00002A
      FF001F43F00010100C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FF0000008000000080
      0000008000008000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000001010
      0C002222EE0010100C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000010100C002222
      EE0010100C000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FF00000080
      0000008000000080000080000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000010100C0010100C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000010100C001010
      0C00000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      0000008000000080000000800000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FF00000080000000800000800000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FF000000800000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000FF000000
      FF00000080008080800000000000000000000000000000000000000000000000
      FF00808080000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF0000000000FFFF
      FF000000000000000000FFFFFF000000000000000000000000000000FF000000
      FF000000800000008000808080000000000000000000000000000000FF000000
      FF00000080008080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF0000FFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF0000000000000000000000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000FF000000
      FF0000008000000080000000800080808000000000000000FF000000FF000000
      8000000080000000800080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000080000000800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF0000FFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      FF000000FF00000080000000800000008000808080000000FF00000080000000
      8000000080000000800080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF000080000000800000008000000080000000800000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF0000FFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000000000FFFFFF000000
      000000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000FF000000FF0000008000000080000000FF0000008000000080000000
      8000000080008080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000080000000800000FFFFFF00FFFFFF0000800000FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF000000000000FFFF0000FFFF0000000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF00000000000000000000000000000000000000000000FF
      FF0000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000FF000000FF00000080000000800000008000000080000000
      8000808080000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000800000FFFFFF00FFFFFF0000800000FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF000000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF0000800000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000800000FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000FFFF00000000000000FFFF00FFFF
      FF0000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000FF000000FF000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF0000800000FFFFFF00FFFFFF0000800000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00000000000000000000000000000000000000000000FFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000FFFF00000000000000000000000000000000000000000000FF
      FF00FFFFFF0000FFFF00000000000000000000FFFF0000000000FFFFFF00FFFF
      FF000000000000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000FF000000FF00000080000000800000008000000080008080
      8000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF0000800000FFFFFF00FFFFFF000080000000800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000000000000000000000FF
      FF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000FFFF000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000FF000000FF000000800000008000808080000000FF00000080000000
      8000808080000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF000080000000800000008000000080000000800000FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      000000FFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      FF000000FF00000080000000800080808000000000000000FF000000FF000000
      8000000080008080800000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000080000000800000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000FFFFFF00FFFFFF000000000000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000000000FFFFFF00FFFFFF000000000000000000FFFF
      FF0000000000FFFFFF00FFFFFF00000000000000000000000000000000000000
      FF000000FF0000008000808080000000000000000000000000000000FF000000
      FF00000080000000000080808000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000800000FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF00000000000000000000FFFF00000000000000
      8000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF0000000000000000000000000000000000000000000000
      00000000FF000000FF0000000000000000000000000000000000000000000000
      FF000000FF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000FFFF0000FFFF0000000000000000000000
      8000000000000000000000000000000000000000000000000000000000000000
      FF00000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF000000FF000000FF00000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000200000000100010000000000000100000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000FFFFFFFFF7FF0000
      FFFFFFFFE3FF0000FFFFFFFFC1FF0000F3FFFFCF80FF0000E3FFFFC7007F0000
      C0000003083F0000800000011C1F000000000000BE0F000080000001FF070000
      C0000003FF830000E3FFFFC7FFC10000F3FFFFCFFFE00000FFFFFFFFFFF00000
      FFFFFFFFFFF80000FFFFFFFFFFFD0000FC00E7FF8003FFFFFC00C3E78003C003
      2000C1C38003C0030000C0818003C0030000E0018003C0030000F0038003C003
      0000F8078003C0030000FC0F8003C0030000FC0F800380010000F80F8003C003
      E000F0078003E007F800E0838003F007F000E1C18003F807E001F3E18007FC27
      C403FFF1800FFE67EC07FFFF801FFFFF00000000000000000000000000000000
      000000000000}
  end
end
