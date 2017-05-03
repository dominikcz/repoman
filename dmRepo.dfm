object Repo: TRepo
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 268
  Width = 441
  object alRepoActions: TActionList
    Images = repoIcons
    OnExecute = alRepoActionsExecute
    Left = 136
    Top = 88
    object actDiff: TAction
      Category = 'repo'
      Caption = 'diff'
      ImageIndex = 14
      ShortCut = 16452
      OnExecute = actDiffExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actGraph: TAction
      Category = 'repo'
      Caption = 'graph'
      ImageIndex = 17
      ShortCut = 16455
      OnExecute = actGraphExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actLog: TAction
      Category = 'repo'
      Caption = 'log'
      ImageIndex = 15
      ShortCut = 16460
      OnUpdate = SingleFileActionUpdate
    end
    object actAnnotate: TAction
      Category = 'repo'
      Caption = 'annotate/blame'
      ImageIndex = 16
      OnExecute = actAnnotateExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actAdd: TAction
      Category = 'repo'
      Caption = 'add'
      ImageIndex = 12
      OnUpdate = actAddUpdate
    end
    object actRemove: TAction
      Category = 'repo'
      Caption = 'remove'
      ImageIndex = 13
      OnUpdate = actRemoveUpdate
    end
    object actEdit: TAction
      Category = 'repo'
      Caption = 'edit'
      ImageIndex = 18
      ShortCut = 16397
      OnExecute = actEditExecute
      OnUpdate = SingleFileActionUpdate
    end
    object actHistory: TAction
      Category = 'repo'
      Caption = 'history'
      OnExecute = actHistoryExecute
    end
  end
  object alViewActions: TActionList
    Images = toolbarIcons
    Left = 225
    Top = 80
    object actFlatMode: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'flat mode'
      Checked = True
      Hint = 'toggle flat mode'
      ImageIndex = 0
      OnExecute = refreshView
    end
    object actModifiedOnly: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'modified'
      Hint = 'toggle modified'
      ImageIndex = 2
      OnExecute = refreshView
    end
    object actShowUnversioned: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'unversioned'
      Hint = 'toggle unversioned'
      ImageIndex = 3
      OnExecute = refreshView
    end
    object actShowIgnored: TAction
      Category = 'view'
      AutoCheck = True
      Caption = 'ignored'
      Hint = 'toggle ignored'
      ImageIndex = 4
      OnExecute = refreshView
    end
    object actRefresh: TAction
      Category = 'view'
      Caption = 'refresh'
      ImageIndex = 5
      SecondaryShortCuts.Strings = (
        'Ctrl+R')
      ShortCut = 116
      OnExecute = actRefreshExecute
    end
  end
  object repoIcons: TPngImageList
    PngImages = <
      item
        Background = clWindow
        Name = 'file'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100804000000B5FA37
          EA0000000467414D410000B18F0BFC610500000002624B474400FF878FCCBF00
          0000097048597300000EC300000EC301C76FA8640000000774494D4507E10408
          102225D168DDBF0000000976704167000001700000001000F245A92D0000004B
          4944415478DA63FCCFD0F89F0103D433C2588C2005F568D207190EC095E05060
          CFD00855825501CCFCFF8C480AE09632FC879AE280AA8001C31A075C26404C19
          8926383060037005F8010085B64D0102F36F780000002574455874646174653A
          63726561746500323031372D30342D30385431363A33333A35332B30323A3030
          19E5CCF90000002574455874646174653A6D6F6469667900323031372D30342D
          30385431363A33343A33372B30323A3030B84442A80000000049454E44AE4260
          82}
      end
      item
        Background = clWindow
        Name = 'unversioned'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FFFFFFC0C0C000000000008027A397DB00
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000200000000000DD86B3F8000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D0000004F4944415478DA636414606060F8FF818191
          5111C8E03F0F6508DCFB00612831EC0132980DCE32089D01328C19FE5E00330C
          2E189F05331818600C63061803AA18C10002EC22462006E31946062800004206
          1B114C7A9A460000002574455874646174653A63726561746500323031372D30
          342D30385431363A33333A35332B30323A303019E5CCF9000000257445587464
          6174653A6D6F6469667900323031372D30342D30385431363A33343A33372B30
          323A3030B84442A80000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'added'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FF0000C0C0C0FFFFFF000000C1C23AF400
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000300000000000DE50B163000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D0000004B4944415478DA636414606060F8FF818191
          5111C8E03F0F6508DDF900611833AC06310C2E30089F06329819FEA2310C2E18
          5C00338C19FE5E4015813380E63060671881184CA71919A000006BC61C11BE44
          93CC0000002574455874646174653A63726561746500323031372D30342D3038
          5431363A33333A35332B30323A303019E5CCF90000002574455874646174653A
          6D6F6469667900323031372D30342D30385431363A33343A33372B30323A3030
          B84442A80000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'conflict'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FF0000C0C0C0FFFFFF000000C1C23AF400
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000400000000000D572BCA2000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D0000004F4944415478DA636414606060F8FF818191
          5111C8E03F0F6508DDF900643029FC1366580D6428DD53BA277C9A915159EE01
          D33F288381813003A218AE1D64E00330036805588D1188C1749A91010A0069C3
          2011A21AB2580000002574455874646174653A63726561746500323031372D30
          342D30385431363A33333A35332B30323A303019E5CCF9000000257445587464
          6174653A6D6F6469667900323031372D30342D30385431363A33343A33372B30
          323A3030B84442A80000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'resolved'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FF0000C0C0C0FFFFFF000000C1C23AF400
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000500000000000D6A4BE39000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D000000454944415478DA636414606060F8FF818191
          5111C8E03F0F6508DDF9C0C8A8ACC0F04F9861359021F740E99EF069FC0CA0E2
          0784D4C018202B18400C231083E934230314000084DE24119266158400000025
          74455874646174653A63726561746500323031372D30342D30385431363A3333
          3A35332B30323A303019E5CCF90000002574455874646174653A6D6F64696679
          00323031372D30342D30385431363A33343A33372B30323A3030B84442A80000
          000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'modified '
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FF0000C0C0C0FFFFFF000000C1C23AF400
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000B00000000000C0E0A5BB000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D0000003E4944415478DA636414606060F8FF818191
          5111C8E03F0F6508DDF900611833AC06328C19FE5E103E0D116100338C1918FE
          3EA65CC408C4603ACDC8000500F17F1B119BF448B10000002574455874646174
          653A63726561746500323031372D30342D30385431363A33333A35332B30323A
          303019E5CCF90000002574455874646174653A6D6F6469667900323031372D30
          342D30385431363A33343A33372B30323A3030B84442A80000000049454E44AE
          426082}
      end
      item
        Background = clWindow
        Name = 'deleted'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FF0000C0C0C0000000FFFFFF31D9765700
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000F00000000000CFB8AFD7000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D000000614944415478DA55CDCB0D80300C0350270B
          F019A02A6112606D46406202AA8C503140208572C0A727398A895A005706D1E0
          6876C7A4407764A2312804AB57922A3870EAB7722CA60F387E3079ABA86C3FF8
          1F0E678101B160491573F655DA08353774442611F24559DC0000002574455874
          646174653A63726561746500323031372D30342D30385431363A33333A35332B
          30323A303019E5CCF90000002574455874646174653A6D6F6469667900323031
          372D30342D30385431363A33343A33372B30323A3030B84442A8000000004945
          4E44AE426082}
      end
      item
        Background = clWindow
        Name = 'missing'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100804000000B5FA37
          EA0000000467414D410000B18F0BFC610500000002624B474400FF878FCCBF00
          0000096F464673000000600000000000D2DEB994000000097048597300000EC3
          00000EC301C76FA8640000000774494D4507E10408102225D168DDBF00000009
          76704167000001700000001000F245A92D0000005F4944415478DA9DCECB0DC0
          200C03507BB2B2196533982C6D2889402AFDE00302E74981822468D921E07902
          91D65141B447058282EC640236A4463A6063BD5D114E80A620FC04E378057CF8
          C3486E414FD6C0EB8A2908B5D282927D9D83E71CF0CA6701F6F97F2000000025
          74455874646174653A63726561746500323031372D30342D30385431363A3333
          3A35332B30323A303019E5CCF90000002574455874646174653A6D6F64696679
          00323031372D30342D30385431363A33343A33372B30323A3030B84442A80000
          000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'dir'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FFFF00C0C0C0FFFFFF000000DBF9A95E00
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000700000000000D108BB0F000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D000000624944415478DA5D8DCB098030104467C402
          829E05B1025BF0D3826D076C408229C0E03DAB713517F7F478CCCC12DF113438
          14AA165B48C00E90808B9C34B2924378C093E32E28E44CA68EBE71C9CC06B050
          83E8DE4C6FA126B78CEE94C4929FE20737B9EC1C3302064E4700000025744558
          74646174653A63726561746500323031372D30342D30385431363A33333A3533
          2B30323A303019E5CCF90000002574455874646174653A6D6F64696679003230
          31372D30342D30385431363A33343A33372B30323A3030B84442A80000000049
          454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'dir unversioned'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FFFF00C0C0C0FFFFFF000000DBF9A95E00
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000800000000000C49AA216000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D000000454944415478DA636480024606460186F760
          869002C3BD0F4006A31203C3BF0F0CFF19199DC14A2E32323A7E00311E33323A
          3D00313E912822003687859121146629031A0300154116338B569D2400000025
          74455874646174653A63726561746500323031372D30342D30385431363A3333
          3A35332B30323A303019E5CCF90000002574455874646174653A6D6F64696679
          00323031372D30342D30385431363A33343A33372B30323A3030B84442A80000
          000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'dir missing'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FFFF00C0C0C0FFFFFF000000DBF9A95E00
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000900000000000C74CA08D000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D0000005D4944415478DA5DCDC10D40401445D1FB42
          0113154C54A005D4A06F143011D6C2D833C6848DBFBA39C9CB17EF0999B0A728
          AC239654B20A82D49E643048F5663C2C52E3EC0C4794F1B23FD9E7488F4C3E98
          24DFCA50F5908BEE7BCA2F6EF5FC2133B25434FE000000257445587464617465
          3A63726561746500323031372D30342D30385431363A33333A35332B30323A30
          3019E5CCF90000002574455874646174653A6D6F6469667900323031372D3034
          2D30385431363A33343A33372B30323A3030B84442A80000000049454E44AE42
          6082}
      end
      item
        Background = clWindow
        Name = 'up'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445FFFFFF808080FFFF00C0C0C0FFFFFF000000DBF9A95E00
          00000174524E530040E6D86600000001624B47440088051D48000000096F4646
          73000000A00000000000C336A720000000097048597300000EC300000EC301C7
          6FA8640000000774494D4507E10408102225D168DDBF00000009767041670000
          01700000001000F245A92D000000604944415478DA5D8DCB0D40501444CF240A
          101A1015880E5083B68506E48502BCD8FB3CD767E1AE4E4E66E68AE784621683
          2463F40194C3EE39A4C6228354F9CCC12CD553D1C11A4CCAE6CCB8A2BFCD9771
          257466AE7A30B1ED44A27D9FF28313BEF01C331CED345E000000257445587464
          6174653A63726561746500323031372D30342D30385431363A33333A35332B30
          323A303019E5CCF90000002574455874646174653A6D6F646966790032303137
          2D30342D30385431363A33343A33372B30323A3030B84442A80000000049454E
          44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'add'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800000808080FFFFFFC0C0C0FF00000000008800005946
          6C550000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F160A06
          B708466C0000001063614E76000000F0000000100000000000000000E5683C4E
          000000454944415478DA636410640082F70C8C0C42020C0C8C6F3F80184AF718
          FFDD8730980D7E0319460C0CF7187591194029063406D01C6219C20A205B6519
          21B633D833324001001FF10FD1EEA04F490000002574455874646174653A6372
          6561746500323031372D30342D31355432323A31303A30362B30323A30308252
          29AF0000002574455874646174653A6D6F6469667900323031372D30342D3135
          5432323A31303A30362B30323A3030F30F91130000000049454E44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'remove'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000009504C54458000000000008800000A10A3B70000000174524E530040
          E6D86600000001624B474402660B7C64000000097048597300000B1300000B13
          01009A9C180000000774494D4507E1040F160A06B708466C0000001063614E76
          000000F0000000100000003000000000444984C8000000474944415478DA558D
          D11100200842618274FF217503A3B2EEE2470E9F42B408AFD4341904E041D02A
          3992DA5A7888510E61CB28C2973CC6FB6A1396FD90752BC4B070BA5E7B6B02FA
          BD1A31F1C4AAEE0000002574455874646174653A63726561746500323031372D
          30342D31355432323A31303A30362B30323A3030825229AF0000002574455874
          646174653A6D6F6469667900323031372D30342D31355432323A31303A30362B
          30323A3030F30F91130000000049454E44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'diff'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800000FF00008080800000FFC0C0C000FF008800001629
          F0BC0000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F160A06
          B708466C0000001063614E76000000F0000000100000009000000000346E1B5E
          000000634944415478DA63640001810F0C8C6086E07B204310C4FAFF01CA607C
          C7C8C0A4C0C0F09EFF01500DF35F06A17720C5C667C1920CCC0620FA2C8CF116
          24F51EC8F80752ACA8C0B3016CB28A82E06A202314A4E4F70628E3EF3A88C9C6
          A71F406C0702002268165166CD60E00000002574455874646174653A63726561
          746500323031372D30342D31355432323A31303A30362B30323A3030825229AF
          0000002574455874646174653A6D6F6469667900323031372D30342D31355432
          323A31303A30362B30323A3030F30F91130000000049454E44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'log'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445800000808080FFFFFFC0C0C00000008800000FE1617A00
          00000174524E530040E6D86600000001624B474405F86FE9C700000009704859
          7300000B1300000B1301009A9C180000000774494D4507E1040F160A06B70846
          6C0000001063614E76000000F000000010000000A000000000954FA3D8000000
          464944415478DA636410640082F70C8C0C42020C0C8C6F3F001946F71818FFDD
          87883029FC01319418EE31CA424418C00CA01A06541152D4082B806CE56584D8
          CEA0CFC80005006E0E0F117E76AE5C0000002574455874646174653A63726561
          746500323031372D30342D31355432323A31303A30362B30323A3030825229AF
          0000002574455874646174653A6D6F6469667900323031372D30342D31355432
          323A31303A30362B30323A3030F30F91130000000049454E44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'annotate'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          520000000C504C5445800000000000FFFFFF8800004AAD78FF0000000174524E
          530040E6D86600000001624B474403110C4CF2000000097048597300000B1300
          000B1301009A9C180000000774494D4507E1040F160A06B708466C0000001063
          614E76000000F000000010000000C0000000000C7DD495000000544944415478
          DA55CDC115C0200803D064824636E8FE43B981D2054A41BD3470F8873C204E98
          ABB9611AFE036FCC9C4270C19440145C932FAB42619012C3D56988969502AAE2
          B4EB11303C3B408B5E2F12EBE0C90746CC1F63EEF54A71000000257445587464
          6174653A63726561746500323031372D30342D31355432323A31303A30362B30
          323A3030825229AF0000002574455874646174653A6D6F646966790032303137
          2D30342D31355432323A31303A30362B30323A3030F30F91130000000049454E
          44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'graph'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C544580000000000000008000FFFF808080FF00FF880000133B
          74CC0000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F160A06
          B708466C0000001063614E76000000F000000010000000D0000000006C9D4317
          000000504944415478DA636480024638439081E1FF0706810F8C42020CEF3E30
          1A9C87301C2FFD0531DE0395FC078B7CFCEF0863407581196033FE03B5434C0D
          580F61385CF90D610800B5436C72FCCF88613B0052D01DD1343914DC00000025
          74455874646174653A63726561746500323031372D30342D31355432323A3130
          3A30362B30323A3030825229AF0000002574455874646174653A6D6F64696679
          00323031372D30342D31355432323A31303A30362B30323A3030F30F91130000
          000049454E44AE426082}
      end
      item
        Background = clFuchsia
        Name = 'edit'
        PngImage.Data = {
          89504E470D0A1A0A0000000D49484452000000100000001008060000001FF3FF
          6100000006624B474400FF00FF00FFA0BDA793000000097048597300000B1300
          000B1301009A9C180000000774494D4507E104160B172CAA30CB900000001D69
          545874436F6D6D656E7400000000004372656174656420776974682047494D50
          642E65070000032F4944415478DA75935968134118C7FF9B6D4C7AC436491B5B
          B5F5022B2A542D1E54D427C5FB00C993373E884AF1C42751B15EB5A208FAE26D
          2B1EE07D3E1451D1A6ADADA058AB8D6968DC26A9B169638EDDECECEC38D52A06
          F1835D86617FBFF98E5901FD515DEB59596259D45CF769E92AADADFBD6CCA5B1
          F9E51F6AAAAF972E5CBFF7FC9C64F1D66BE12D435D27AB77E4636555F03706A1
          EFB5F6D292534E7DD2467FF40B4C86714C26AF0585CC8523E30E7CB1356C785E
          9D10FE3E1FB18E9915DB4F6037FE8A9F828395F5CC643763CAF097E816CB3038
          E71D3EB7E623AB380D941F9639B618EE375EDCBE75F96A6DCDD9151CD1530415
          475C6C8C732A0AAD02140D50A88ED6840433B341660C5185C0ED23609EF6A69A
          CD65651C212982CA63F52C34A310E31D405233F2CD0C7424BE2153CC46444D42
          652224BF8021A2413B3ECF3686239E1441D531175366DB614ECB86A2F7490049
          0EC39A960F591311D729BEF8294A0AEC787D66EFCE5797F655A5080E1C696093
          D75970D76D85686450A98167F01503C53C68BA094417D0155430B12017F1D6C6
          C6EA4DD3FBCAA07F04FBB960FDF621D8FF92676054F9A93A3AE410B2052B5442
          20F2127AFC2A260CCA41BAA891938BF24A38D69A92C1F22D19B8FA361F9FE399
          48120552C2871C5841F89A528268978ED23C1BCC160B9A6E1EDDFAEA62C589BF
          A6D0C0E69633B4FB0B71A54580591711E0028B6001E14DA4BA86DE4012A58E5C
          089C882B81A7359B66CDEE1B67FF3D686053364410934DB85C3712BA9C400FEF
          815D7420A146A0538A70208E49763BA81C877954A172CA39AC98A3BEFE121AD9
          C27223C24A18171A87A2B7238A50A2130E61101887559DA1BB8762FAE822C03C
          0042563A8E2FB02DE6E8FD5F029E81B3DC0A99D7FBC89B8E67AE0812468211B9
          45C8CDB620DDD6055F4B27693A77FA7ED8E7690E7E6A6E13D306D4534D95FA7B
          50CF566F2B804228BA92BD7C0202BCAC16634D53D113E1F7A277349E3FF846AE
          EF99B60C883DFCE75F385CE96245CE989E454718242907E1A048DE7E0C25A596
          1792D7E30EC483CFDF2442EFDBA91ABBC73F97FE11ECAC3CB4EBC66356A6C482
          512DD2E6ED6E7BF2916FBBF91314044327633AC57FE207FCCE9620187DFCF200
          00000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'itemlist.png_d-5'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800000808080FFFFFFC0C0C00000FF000000880000823F
          2A2E0000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E104160D1B11
          5A60B43F0000001063614E7600000080000000100000005000000000678F8F01
          0000004A4944415478DA636410640082F70C8C0C42020C0C8C6F3F4019FFEE03
          19464029C1DF4086C123B947FF7541524C720F1849672831DC833080068218C2
          0A205B651921B633D83332400100D47613D1C05B59B300000025744558746461
          74653A63726561746500323031372D30342D32325431333A32373A31372B3032
          3A30309C2500520000002574455874646174653A6D6F6469667900323031372D
          30342D32325431333A32373A31372B30323A3030ED78B8EE0000000049454E44
          AE426082}
      end
      item
        Background = clWindow
        Name = 'itemlist.png_d-6'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000018504C5445800000808080FFFFFF0000FFC0C0C0000000FF00008800
          00E3D4A2340000000174524E530040E6D86600000001624B474407166188EB00
          0000097048597300000B1300000B1301009A9C180000000774494D4507E10416
          0D1B115A60B43F0000001063614E7600000080000000100000006000000000C6
          AE3787000000624944415478DA636410640082F70C8C0C420A1F1898DE7C8032
          FEDE0732048052C6BF19198415FE038574800C7E11833F877420220E200650B1
          0BC3BF37601183034E2006BF0094A1F0DF042C05368709A218C2103100D9CAC3
          08B19DC19E91010A001E791ED18C00CDA70000002574455874646174653A6372
          6561746500323031372D30342D32325431333A32373A31372B30323A30309C25
          00520000002574455874646174653A6D6F6469667900323031372D30342D3232
          5431333A32373A31372B30323A3030ED78B8EE0000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'itemlist.png_d-7'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000018504C5445800000808080FFFFFFC0C0C00000FF000000FF00008800
          00ED9E242E0000000174524E530040E6D86600000001624B474407166188EB00
          0000097048597300000B1300000B1301009A9C180000000774494D4507E10416
          0D1B115A60B43F0000001063614E7600000080000000100000007000000000A6
          4EA005000000614944415478DA636410640082F70C8C0C42020C0C8C6F3F0019
          420A0CFFEFDD073118E418847F83A498E41E30EA62672831DC833080E6801946
          0C4A7F0E8218068FFE391C84883C72F8FB162CC2F4C711C8103664F864001201
          DBCE60CFC8000500BCE11CD1F39F2BD80000002574455874646174653A637265
          61746500323031372D30342D32325431333A32373A31372B30323A30309C2500
          520000002574455874646174653A6D6F6469667900323031372D30342D323254
          31333A32373A31372B30323A3030ED78B8EE0000000049454E44AE426082}
      end>
    Left = 328
    Top = 152
    Bitmap = {}
  end
  object ActionManager1: TActionManager
    ActionBars = <
      item
        Items.CaptionOptions = coAll
        Items = <
          item
            Action = actFlatMode
            Caption = '&flat mode'
            ImageIndex = 0
          end
          item
            Action = actModifiedOnly
            Caption = '&modified'
            ImageIndex = 2
          end
          item
            Action = actShowIgnored
            Caption = '&ignored'
            ImageIndex = 4
          end
          item
            Action = actShowUnversioned
            Caption = '&unversioned'
            ImageIndex = 3
          end
          item
            Action = actRefresh
            Caption = '&refresh'
            ImageIndex = 5
            ShortCut = 116
          end
          item
            Caption = '-'
          end
          item
            Action = actDiff
            ImageIndex = 14
            ShortCut = 16452
          end
          item
            Action = actGraph
            Caption = '&graph'
            ImageIndex = 17
            ShortCut = 16455
          end
          item
            Action = actLog
            Caption = '&log'
            ImageIndex = 15
            ShortCut = 16460
          end
          item
            Action = actAnnotate
            Caption = '&annotate/blame'
            ImageIndex = 16
          end
          item
            Action = actEdit
            ImageIndex = 18
            ShortCut = 16397
          end
          item
            Action = actHistory
            Caption = '&history'
          end
          item
            Caption = '-'
          end
          item
            Action = actAdd
            Caption = 'a&dd'
            ImageIndex = 12
          end
          item
            Action = actRemove
            Caption = 'r&emove'
            ImageIndex = 13
          end>
        ActionBar = MainForm.ActionToolBar1
      end>
    LinkedActionLists = <
      item
        ActionList = alViewActions
        Caption = 'alViewActions'
      end
      item
        ActionList = alRepoActions
        Caption = 'alRepoActions'
      end>
    Images = repoIcons
    Left = 328
    Top = 32
    StyleName = 'Platform Default'
  end
  object toolbarIcons: TPngImageList
    PngImages = <
      item
        Background = clWhite
        Name = 'flat'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          520000000467414D410000B18F0BFC610500000009504C544580008000000088
          0088616542570000000174524E530040E6D86600000001624B474402660B7C64
          000000097048597300000B1300000B1301009A9C180000000774494D4507E104
          0F0C1A2ADEA31E780000001063614E76000000F0000000100000000000000000
          E5683C4E000000354944415478DA63648002467C0C4186FF1FA00C86F78CFF21
          8CFF8CEFC16A180518200C90240A032803610005A05240E67B7C7601006D620C
          117BC1792C0000002574455874646174653A63726561746500323031372D3034
          2D31355430353A30373A32332B30323A30302D00073900000025744558746461
          74653A6D6F6469667900323031372D30342D31355431323A32363A34322B3032
          3A30306B9788670000000049454E44AE426082}
      end
      item
        Background = clNone
        Name = 'filter'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000012504C5445800080808080FFFFFF000000C0C0C088008830B3440100
          00000174524E530040E6D86600000001624B474405F86FE9C700000009704859
          7300000B1300000B1301009A9C180000000774494D4507E1040F0C1A2ADEA31E
          780000001063614E76000000F00000001000000010000000008588ABCC000000
          464944415478DA63648002460443104CFF6764101200D1FC8C0C8CCA0A0C7F2F
          BD05AA113262382B7F01C8605496BDF416AC4B44F7FD05A219820CF21006B3C1
          DF0BC896420100154916514E711FB80000002574455874646174653A63726561
          746500323031372D30342D31355430353A30373A32332B30323A30302D000739
          0000002574455874646174653A6D6F6469667900323031372D30342D31355431
          323A32363A34322B30323A30306B9788670000000049454E44AE426082}
      end
      item
        Background = clNone
        Name = 'modified'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800080808080000000FF0000FFFFFFC0C0C0880088BB67
          ED710000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F0C1A2A
          DEA31E780000001063614E76000000F0000000100000004000000000BD9B6407
          000000674944415478DA35CC3B0A80301004D059ED35210748B00F7872EF601D
          F00662B0D7F8E9D7CF46B799E10D2C690009059371C0B8C149A97A0729E999C9
          D88DD412F38465E657A0134791EBF49D48697510399C0A595A64998C1F44EA1D
          EBFFC752F324383684EF6E23992368104AB3550000002574455874646174653A
          63726561746500323031372D30342D31355430353A30373A32332B30323A3030
          2D0007390000002574455874646174653A6D6F6469667900323031372D30342D
          31355431323A32363A34322B30323A30306B9788670000000049454E44AE4260
          82}
      end
      item
        Background = clNone
        Name = 'unversioned'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800080808080FFFFFFC0C0C00000000000808800888422
          05670000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F0C1A2A
          DEA31E780000001063614E76000000F000000010000000B000000000F5AF345A
          0000006B4944415478DA2DCC4D0E40301404E079E996685D40FC6C1BC2F52D1C
          8070025C40525D6BAA7F6FF56566F288386015405403C59EC04F15D160F698CC
          51AE0EDD802DC230A9BFC56F587FD1EA313DB7C81D987C6F1EA1B4CDC31F5D51
          1692BD451803255C353A901584743F0BAD1DA69DC0D810000000257445587464
          6174653A63726561746500323031372D30342D31355430353A30373A32332B30
          323A30302D0007390000002574455874646174653A6D6F646966790032303137
          2D30342D31355431323A32363A34322B30323A30306B9788670000000049454E
          44AE426082}
      end
      item
        Background = clNone
        Name = 'ignored'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          5200000015504C5445800080808080FFFFFFC0C0C00000FF000000880088FB4D
          F96C0000000174524E530040E6D86600000001624B4744066166B87D00000009
          7048597300000B1300000B1301009A9C180000000774494D4507E1040F0C1A2A
          DEA31E780000001063614E76000000F000000010000000D0000000006C9D4317
          000000784944415478DA2DCDC109C2401085E1FFB116B0D9788F68038BA684A4
          5A5BF0600111F6AE042D40B4003771366460E0E3F18651057C6C153C7A7F574C
          87CB02D7505047AB2CC91E7ED79234E454CA61477EE1148EE8214EDA46C6B94D
          D1203FB464C3C8BC893775540C8A49DDF4C4DDEDBCF7F6FA6C609D3F6B3B1E87
          F50316470000002574455874646174653A63726561746500323031372D30342D
          31355430353A30373A32332B30323A30302D0007390000002574455874646174
          653A6D6F6469667900323031372D30342D31355431323A32363A34322B30323A
          30306B9788670000000049454E44AE426082}
      end
      item
        Background = clWindow
        Name = 'refresh'
        PngImage.Data = {
          89504E470D0A1A0A0000000D4948445200000010000000100403000000EDDDE2
          520000000F504C5445800080000000FFFFFF008000880088E172830400000001
          74524E530040E6D86600000001624B4744048F68D95100000009704859730000
          0B1300000B1301009A9C180000000774494D4507E1040F0C1A2ADEA31E780000
          001063614E76000000F000000010000000E000000000CDBCFB910000004B4944
          415478DA35CD4B11C0400803D0C4012B61FD8BAA830607945FB9F026C0401AB2
          04F2660FF9024FC3E4D138C25B38082F50771286F902D6235434CB1AE493FF5C
          C0EE34FA3B82D8FA00F06B24D1DCEC3E890000002574455874646174653A6372
          6561746500323031372D30342D31355430353A30373A32332B30323A30302D00
          07390000002574455874646174653A6D6F6469667900323031372D30342D3135
          5431323A32363A34322B30323A30306B9788670000000049454E44AE426082}
      end>
    Left = 232
    Top = 208
    Bitmap = {}
  end
  object popupRepoActions: TPopupActionBar
    Images = repoIcons
    Left = 224
    Top = 144
    object diff1: TMenuItem
      Action = actDiff
    end
    object graph1: TMenuItem
      Action = actGraph
    end
    object log1: TMenuItem
      Action = actLog
    end
    object annotateblame1: TMenuItem
      Action = actAnnotate
    end
    object edit1: TMenuItem
      Action = actEdit
    end
    object history1: TMenuItem
      Action = actHistory
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object add1: TMenuItem
      Action = actAdd
    end
    object remove1: TMenuItem
      Action = actRemove
    end
  end
end
