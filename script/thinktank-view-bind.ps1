


#region Key Command Binding
#########################################################################################################################
[ScriptBlock] $global:TTPreviewKeyDown = { # Bind to AppMan, PopupMenu, Cabinet

    $source =   [string]($args[0].Name) # ⇒ Application, Cabinet, PopupMenu
    $mod =      [string]($args[1].KeyboardDevice.Modifiers)
    $key =      if( $mod -in @('Alt','Alt, Shift') ){ [string]($args[1].SystemKey) }else{ [string]($args[1].Key) }
    $tttv  =    [TTTentativeKeyBindingMode]::Name
    $panel =    $global:appcon._get('Focus.Application')

    if( $source -eq 'Application' ){        #### Application
        if( $tttv -ne '' ){                 #### tentative Index/Library/Shelf
            $panel = $tttv
            $command = try{ $global:TTKeyEvents["$panel+"][$mod][$key] }catch{ $null }

        }else{                              #### non tentative

            $command = try{ $global:TTKeyEvents['Application'][$mod][$key] }catch{ $null }

            if( 0 -ne $command.length ){    #### Application
                $panel = $source

            }else{
                if( $panel -match "(?<panel>Editor|Browser|Grid)[123]" ){
                    $command = try{ $global:TTKeyEvents[$Matches.panel][$mod][$key] }catch{ $null }

                }elseif( $panel -eq 'Desk' ){
                    $command = try{ $global:TTKeyEvents['Desk'][$mod][$key] }catch{ $null }

                }else{                      #### normal Index/Library/Shelf
                    $command = @( "$panel+", $panel ).foreach{
                        try{ $global:TTKeyEvents[$_][$mod][$key] }catch{ $null }
                    }.where{ $null -ne $_ }[0]
                }
            }
        }
        
    }else{                                  #### PopupMenu / Cabinet 
        $panel = $source
        $command = try{ $global:TTKeyEvents[$panel][$mod][$key] }catch{ $null }    

    }

    if( 0 -ne $command.length ){
        if( $global:TTKeyEventMessage ){
            Write-Host "PreviewKeyDown source:$source, tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
        }
        switch ( Invoke-Expression "$command '$panel' '$mod' '$key'" ){
            'cancel' { $args[1].Handled = $false }
            default { $args[1].Handled = $true }
        }
    }else{
        $args[1].Handled = $false
    }
 
}
[ScriptBlock] $global:TTPreviewKeyUp = { # Bind to AppMan, PopupMenu, Cabinet
    if( [TTTentativeKeyBindingMode]::Check( $args[1].Key ) ){
        ttcmd_menu_cancel 'PopupMenu' '' ''
        $args[1].Handled = $True
    }
}
$global:TTKeyEventMessage = $true
$global:TTKeyEvents = @{}
$global:TTEventKeys = @{}

function KeyBindingSetup(){

    $keybinds = ( @(  
        $global:KeyBind_Application,    $global:KeyBind_Cabinet,    $global:KeyBind_Library, 
        $global:KeyBind_Index,          $global:KeyBind_Shelf,      $global:KeyBind_Misc, 
        $global:KeyBind_Desk,           $global:KeyBind_Editor,     $global:KeyBind_PopupMenu  ) -join "`n" )

    $keybinds.split("`n").foreach{
        $kb_fmt = "(?<mode>[^ ]+)\s{2,}(?<mod>[^ ]+( [^ ]+)?)\s{2,}(?<key>[^ ]+)\s{2,}(?<command>[^\s]+)\s*"
        if( $_ -match $kb_fmt ){
            $global:TTKeyEvents[$Matches.mode] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod] += @{}
            $global:TTKeyEvents[$Matches.mode][$Matches.mod][$Matches.key] = $Matches.command
            $global:TTEventKeys[$Matches.command] += @()
            $global:TTEventKeys[$Matches.command] += @( @{ Mode = $Matches.mode; Key = "[$($Matches.mod)]$($Matches.key)" } )
        }
    }
}
#endregion###############################################################################################################







#region Application
#########################################################################################################################
$global:KeyBind_Application = @'
Application     None            Escape      ttcmd_application_window_quit
Application     Alt             S           ttcmd_panel_focus_shelf
Application     Alt             L           ttcmd_panel_focus_library
Application     Alt             I           ttcmd_panel_focus_index
Application     Alt             C           ttcmd_panel_focus_cabinet
Application     Alt             D           ttcmd_panel_focus_deskwork
Application     Alt             W           ttcmd_panel_focus_work_toggle
Application     Alt, Shift      S           ttcmd_panel_collapse_shelf
Application     Alt, Shift      L           ttcmd_panel_collapse_library
Application     Alt, Shift      I           ttcmd_panel_collapse_index
Application     Alt, Shift      C           ttcmd_panel_collapse_cabinet
Application     Alt, SHift      W           ttcmd_panel_focus_work_revtgl
'@
function ttcmd_application_noop( $source, $mod, $key ){
    #.SYNOPSIS
    # ダミーコマンド
    $tttv = [TTTentativeKeyBindingMode]::Name
    $panel =    $global:appcon._get('Focus.Application')

    Write-Host "ttcmd_application_noop source:$source, tentative:$tttv, panel:$panel, mod:$mod, key:$key, command:$command"
    return
}
#region application_window
function ttcmd_application_window_quit( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションを終了する
    
    # param( $sender, $mod, $key )

    switch( [MessageBox]::Show( "終了しますか", "Quit",'YesNo','Question') ){
        'No' { return }
    }
    $global:appcon.view.window( 'State', 'Close' )
}
function ttcmd_application_window_full( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションを最大化する
    
    $global:appcon.view.window( 'State', 'Max' )
}
function ttcmd_application_window_icon( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションを最小化する

    $global:appcon.view.window( 'State', 'Min' )
}
function ttcmd_application_window_free( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーションを通常化する

    $global:appcon.view.window( 'State', 'Normal' )
}
function ttcmd_application_window_turn( $source, $mod, $key ){
    #.SYNOPSIS
    # アプリケーション表示を変更する

    $global:appcon.view.window( 'State', 'toggle' )
}

#endregion
#region panel_focus
function ttcmd_panel_focus_shelf( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfに一時的フォーカス、その後、フォーカス
 
    $global:appcon.group.focus( 'Shelf+', $mod, $key )
}
function ttcmd_panel_focus_library( $source, $mod, $key ){
    #.SYNOPSIS
    # Libraryに一時的フォーカス、その後、フォーカス
 
    $global:appcon.group.focus( 'Library+', $mod, $key )
}
function ttcmd_panel_focus_index( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfに一時的フォーカス、その後、フォーカス
 
    $global:appcon.group.focus( 'Index+', $mod, $key )
}
function ttcmd_panel_focus_cabinet( $source, $mod, $key ){
    #.SYNOPSIS
    # Cabinetに一時的フォーカス、その後、フォーカス
 
    $global:appcon.group.focus( 'Cabinet', $mood, $key )
}
function ttcmd_panel_focus_deskwork( $source, $mod, $key ){
    #.SYNOPSIS
    # DeskとＷorkplaceを交互にフォーカス

    switch( $global:appcon._get('Focus.Application') ){
        'Desk'  { $global:appcon.group.focus( 'Workplace', $mod, $key ) }
        default { $global:appcon.group.focus( 'Desk', $mod, $key ) }
    }
    
}
function ttcmd_panel_focus_work_toggle( $source, $mod, $key ){
    #.SYNOPSIS
    # Ｗorkplaceにフォーカス、その後Work1/2/3をトグル

    switch -regex ( $global:appcon._get('Focus.Application') ){
        "(?<panel>[^123]+)(?<num>[123])" {
            $global:appcon.view.style( 'Work+Focus', 'toggle' )
       
        }
        default{
            $global:appcon.group.focus( 'Workplace', $mod, $key )

        }
    }

}
function ttcmd_panel_focus_work_revtgl( $source, $mod, $key ){
    #.SYNOPSIS
    # Ｗorkplaceにフォーカス、その後Work1/2/3を反転トグル

    switch -regex ( $global:appcon._get('Focus.Application') ){
        "(?<panel>[^123]+)(?<num>[123])" {
            $global:appcon.view.style( 'Work+Focus', 'revtgl' )
       
        }
        default{
            $global:appcon.group.focus( 'Workplace', $mod, $key )

        }
    }

}
function ttcmd_panel_collapse_shelf( $source, $mod, $key ){
    #.SYNOPSIS
    # Shelfを非表示

    $global:appcon.view.style( 'Shelf', 'None' )
    ttcmd_panel_focus_desk $source $mod $key
}
function ttcmd_panel_collapse_library( $source, $mod, $key ){
    #.SYNOPSIS
    # Libraryを非表示

    $global:appcon.view.style( 'Library', 'None' )
    ttcmd_panel_focus_desk $source $mod $key
}
function ttcmd_panel_collapse_index( $source, $mod, $key ){
    #.SYNOPSIS
    # Indexを非表示

    $global:appcon.view.style( 'Index', 'None' )
    ttcmd_panel_focus_desk $source $mod $key
}
function ttcmd_panel_collapse_cabinet( $source, $mod, $key ){
    #.SYNOPSIS
    # Cabinetを非表示

    $global:appcon.menu.close( $source, 'ok' )
}

#endregion

#endregion###############################################################################################################

#region Library/Index/Shelf
#########################################################################################################################
$global:KeyBind_Library = @'
Library+    Alt         L           ttcmd_panel_focus_library
Library+    Alt         P           ttcmd_panel_move_up
Library+    Alt         N           ttcmd_panel_move_down
Library+    Alt, Shift  P           ttcmd_panel_move_first
Library+    Alt, Shift  N           ttcmd_panel_move_last
Library+    Alt         Up          ttcmd_application_border_inlpanel_up
Library+    Alt         Down        ttcmd_application_border_inlpanel_down
Library+    Alt         Left        ttcmd_application_border_inwpanel_left
Library+    Alt         Right       ttcmd_application_border_inwpanel_right
Library+    Alt, Shift  Space       ttcmd_panel_action_invoke
Library+    Alt         Space       ttcmd_panel_action_select
Library+    Alt         D0          ttcmd_panel_reload
Library+    Alt         K           ttcmd_panel_filter_clear
Library+    Alt         D           ttcmd_panel_discard_selected

Library     None        Up          ttcmd_panel_move_up
Library     None        Down        ttcmd_panel_move_down
Library     Shift       Up          ttcmd_panel_move_first
Library     Shift       Down        ttcmd_panel_move_last
Library     None        F1          ttcmd_panel_sort_dsc_1stcolumn
Library     Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Library     None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Library     Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Library     None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Library     Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Library     None        F4          ttcmd_panel_sort_dsc_4thcolumn
Library     Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Library     None        F5          ttcmd_panel_sort_dsc_5thcolumn
Library     Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Library     None        F6          ttcmd_panel_sort_dsc_6thcolumn
Library     Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Library     Shift       Return      ttcmd_panel_action_invoke
Library     None        Return      ttcmd_panel_action_select
'@
$global:KeyBind_Index = @'
Index+      Alt         I           ttcmd_panel_focus_index
Index+      Alt         P           ttcmd_panel_move_up
Index+      Alt         N           ttcmd_panel_move_down
Index+      Alt, Shift  P           ttcmd_panel_move_first
Index+      Alt, Shift  N           ttcmd_panel_move_last
Index+      Alt         Up          ttcmd_application_border_inlpanel_up
Index+      Alt         Down        ttcmd_application_border_inlpanel_down
Index+      Alt         Left        ttcmd_application_border_inwpanel_left
Index+      Alt         Right       ttcmd_application_border_inwpanel_right
Index+      Alt, Shift  Space       ttcmd_panel_action_invoke
Index+      Alt         Space       ttcmd_panel_action_select
Index+      Alt         D0          ttcmd_panel_reload
Index+      Alt         K           ttcmd_panel_filter_clear
Index+      Alt         D           ttcmd_panel_discard_selected

Index       None        Up          ttcmd_panel_move_up
Index       None        Down        ttcmd_panel_move_down
Index       Shift       Up          ttcmd_panel_move_first
Index       Shift       Down        ttcmd_panel_move_last
Index       None        F1          ttcmd_panel_sort_dsc_1stcolumn
Index       Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Index       None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Index       Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Index       None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Index       Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Index       None        F4          ttcmd_panel_sort_dsc_4thcolumn
Index       Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Index       None        F5          ttcmd_panel_sort_dsc_5thcolumn
Index       Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Index       None        F6          ttcmd_panel_sort_dsc_6thcolumn
Index       Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Index       Shift       Return      ttcmd_panel_action_invoke
Index       None        Return      ttcmd_panel_action_select
'@
$global:KeyBind_Shelf = @'
Shelf+      Alt         S           ttcmd_panel_focus_shelf
Shelf+      Alt         P           ttcmd_panel_move_up
Shelf+      Alt         N           ttcmd_panel_move_down
Shelf+      Alt, Shift  P           ttcmd_panel_move_first
Shelf+      Alt, Shift  N           ttcmd_panel_move_last
Shelf+      Alt         Up          ttcmd_application_border_inrpanel_up
Shelf+      Alt         Down        ttcmd_application_border_inrpanel_down
Shelf+      Alt         Left        ttcmd_application_border_inwpanel_left
Shelf+      Alt         Right       ttcmd_application_border_inwpanel_right
Shelf+      Alt, Shift  Space       ttcmd_panel_action_invoke
Shelf+      Alt         Space       ttcmd_panel_action_select
Shelf+      Alt         D0          ttcmd_panel_reload
Shelf+      Alt         K           ttcmd_panel_filter_clear
Shelf+      Alt         D           ttcmd_panel_discard_selected

Shelf       None        Up          ttcmd_panel_move_up
Shelf       None        Down        ttcmd_panel_move_down
Shelf       Shift       Up          ttcmd_panel_move_first
Shelf       Shift       Down        ttcmd_panel_move_last
Shelf       None        F1          ttcmd_panel_sort_dsc_1stcolumn
Shelf       Shift       F1          ttcmd_panel_sort_asc_1stcolumn
Shelf       None        F2          ttcmd_panel_sort_dsc_2ndcolumn
Shelf       Shift       F2          ttcmd_panel_sort_asc_2ndcolumn
Shelf       None        F3          ttcmd_panel_sort_dsc_3rdcolumn
Shelf       Shift       F3          ttcmd_panel_sort_asc_3rdcolumn
Shelf       None        F4          ttcmd_panel_sort_dsc_4thcolumn
Shelf       Shift       F4          ttcmd_panel_sort_asc_4thcolumn
Shelf       None        F5          ttcmd_panel_sort_dsc_5thcolumn
Shelf       Shift       F5          ttcmd_panel_sort_asc_5thcolumn
Shelf       None        F6          ttcmd_panel_sort_dsc_6thcolumn
Shelf       Shift       F6          ttcmd_panel_sort_asc_6thcolumn
Shelf       Shift       Return      ttcmd_panel_action_invoke
Shelf       None        Return      ttcmd_panel_action_select
'@

#region _panel_move_
function ttcmd_panel_move_up( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを上に移動

    $global:appcon.group.cursor( $source, 'up' )
}
function ttcmd_panel_move_down( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを下に移動

    $global:appcon.group.cursor( $source, 'down' )
}
function ttcmd_panel_move_first( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを先頭に移動

    $global:appcon.group.cursor( $source, 'first' )
}
function ttcmd_panel_move_last( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのカーソルを末尾に移動

    $global:appcon.group.cursor( $source, 'last' )
}
#endregion

#region _application_border_inXpanel_
function ttcmd_application_border_inrpanel_up( $source, $mod, $key ){
    #.SYNOPSIS
    # 右パネル内境界を上へ移動

    $global:appcon.view.border( 'Layout.Shelf.Height', "-1" )
}
function ttcmd_application_border_inrpanel_down( $source, $mod, $key ){
    #.SYNOPSIS
    # 右パネル境界を下へ移動

    $global:appcon.view.border( 'Layout.Shelf.Height', "+1" )
}
function ttcmd_application_border_inlpanel_up( $source, $mod, $key ){
    #.SYNOPSIS
    # 左パネル内境界を上へ移動

    $global:appcon.view.border( 'Layout.Library.Height', "-1" )
}
function ttcmd_application_border_inlpanel_down( $source, $mod, $key ){
    #.SYNOPSIS
    # 左パネル境界を下へ移動

    $global:appcon.view.border( 'Layout.Library.Height', "+1" )
}
function ttcmd_application_border_inwpanel_left( $source, $mod, $key ){
    #.SYNOPSIS
    # Window内境界を左へ移動

    $global:appcon.view.border( 'Layout.Library.Width', "-1" )
}
function ttcmd_application_border_inwpanel_right( $source, $mod, $key ){
    #.SYNOPSIS
    # Window内境界を右へ移動

    $global:appcon.view.border( 'Layout.Library.Width', "+1" )
}

#endregion

#region _panel_X_
function ttcmd_panel_action_invoke( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの選択アイテムを実行する

    $global:appcon.group.invoke_action( $source )

}
function ttcmd_panel_action_select( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの選択アイテムを選択・実行する

    $global:appcon.group.select_actions_then_invoke( $source )

}
function ttcmd_panel_reload( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのデータを更新する

    $global:appcon.group.reload( $source )
}
function ttcmd_panel_filter_clear( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルのフィルターをクリアする

    $global:appcon.group.keyword( $source, '' )
}
function ttcmd_panel_discard_selected( $source, $mod, $key ){
    #.SYNOPSIS
    # 選択アイテムの関連リソースを削除する

    $global:appcon.group.action( $source, 'SelectedItems', 'DiscardResources' )
}

#endregion

#region _panel_sort_
function ttcmd_panel_sort_dsc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第１カラムで降順ソートする

    $script:appcon.group.sort( $source, 1, 'Descending' )
}
function ttcmd_panel_sort_asc_1stcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第１カラムで昇順ソートする

    $script:appcon.group.sort( $source, 1, 'Ascending' )
}
function ttcmd_panel_sort_dsc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第２カラムで降順ソートする

    $script:appcon.group.sort( $source, 2, 'Descending' )
}
function ttcmd_panel_sort_asc_2ndcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第２カラムで昇順ソートする

    $script:appcon.group.sort( $source, 2, 'Ascending' )
}
function ttcmd_panel_sort_dsc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第３カラムで降順ソートする

    
    $script:appcon.group.sort( $source, 3, 'Descending' )
}
function ttcmd_panel_sort_asc_3rdcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第３カラムで昇順ソートする

    
    $script:appcon.group.sort( $source, 3, 'Ascending' )
}
function ttcmd_panel_sort_dsc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第４カラムで降順ソートする

    
    $script:appcon.group.sort( $source, 4, 'Descending' )
}
function ttcmd_panel_sort_asc_4thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第４カラムで昇順ソートする

    
    $script:appcon.group.sort( $source, 4, 'Ascending' )
}
function ttcmd_panel_sort_dsc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第５カラムで降順ソートする

    
    $script:appcon.group.sort( $source, 5, 'Descending' )
}
function ttcmd_panel_sort_asc_5thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第５カラムで昇順ソートする

    
    $script:appcon.group.sort( $source, 5, 'Ascending' )
}
function ttcmd_panel_sort_dsc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第６カラムで降順ソートする

    
    $script:appcon.group.sort( $source, 6, 'Descending' )
}
function ttcmd_panel_sort_asc_6thcolumn( $source, $mod, $key ){
    #.SYNOPSIS
    # パネルの第６カラムで昇順ソートする

    
    $script:appcon.group.sort( $source, 6, 'Ascending' )
}

#endregion

#endregion###############################################################################################################

#region Desk
#########################################################################################################################
$global:KeyBind_Desk = @'
Desk        Alt         N           ttcmd_panel_focus_deskwork
Desk        None        down        ttcmd_panel_focus_deskwork
Desk        Alt         Up          ttcmd_application_border_indesk_up
Desk        Alt         Down        ttcmd_application_border_indesk_down
Desk        Alt         Left        ttcmd_application_border_indesk_left
Desk        Alt         Right       ttcmd_application_border_indesk_right
Desk        Alt         K           ttcmd_panel_filter_clear


'Desk        Alt         M           ttcmd_desk_focus_menu
'Desk        Control     N           ttcmd_desk_works_focus_current_norm
'Desk        Control     F           ttcmd_application_textsearch
'@

#region _application_border_indesk_
function ttcmd_application_border_indesk_up( $source, $mod, $key ){
    #.SYNOPSIS
    # Desk内境界を上へ移動

    $global:appcon.view.border( 'Layout.Work1.Height', "-1" )
}
function ttcmd_application_border_indesk_down( $source, $mod, $key ){
    #.SYNOPSIS
    # Desk内境界を下へ移動

    $global:appcon.view.border( 'Layout.Work1.Height', "+1" )

}
function ttcmd_application_border_indesk_left( $source, $mod, $key ){
    #.SYNOPSIS
    # Desk内境界を左へ移動

    $global:appcon.view.border( 'Layout.Work1.Width', "-1" )
}
function ttcmd_application_border_indesk_right( $source, $mod, $key ){
    #.SYNOPSIS
    # Desk内境界を右へ移動

    $global:appcon.view.border( 'Layout.Work1.Width', "+1" )
}
#endregion

#endregion###############################################################################################################


#region Editor
#########################################################################################################################
$global:KeyBind_Editor = @'
Editor      Control         P               ttcmd_editor_move_toprevline
Editor      Control         N               ttcmd_editor_move_tonextline
Editor      Control         B               ttcmd_editor_move_leftchar
Editor      Control         F               ttcmd_editor_move_rightchar
Editor      Control         A               ttcmd_editor_move_tolinestart
Editor      Control         E               ttcmd_editor_move_tolineend
Editor      Control         K               ttcmd_editor_delete_tolineend
Editor      Alt             P               ttcmd_editor_move_toprevkeyword
Editor      Alt             N               ttcmd_editor_move_tonextkeyword
Editor      Alt             B               ttcmd_editor_outline_fold_section
Editor      Alt             F               ttcmd_editor_outline_collapse_section
Editor      Alt             Up              ttcmd_editor_outline_moveto_previous
Editor      Alt             Down            ttcmd_editor_outline_moveto_next
Editor      Alt             Left            ttcmd_editor_outline_fold_section
Editor      Alt             Right           ttcmd_editor_outline_collapse_section


xEditor      None            PageUp          ttcmd_editor_scroll_toprevline
xEditor      None            Next            ttcmd_editor_scroll_tonextline
xEditor      None            BrowserBack     ttcmd_editor_scroll_toprevline
xEditor      None            BrowserForward  ttcmd_editor_scroll_tonextline
xEditor      None            Return          ttcmd_editor_scroll_tonewline
xEditor      Alt             T               ttcmd_editor_edit_insert_date
xEditor      Alt             V               ttcmd_editor_edit_insert_clipboard
xEditor      Alt             C               ttcmd_editor_copy_tag_atcursor
xEditor      Alt             D1              ttcmd_desk_works_focus_work1
xEditor      Alt             D2              ttcmd_desk_works_focus_work2
xEditor      Alt             D3              ttcmd_desk_works_focus_work3
xEditor      Alt             M               ttcmd_desk_focus_menu
xEditor      Alt             OemBackslash    ttcmd_application_config_editor_wordwrap_toggle
xEditor      Alt             PageUp          ttcmd_editor_scroll_tonextline
xEditor      Alt             Next            ttcmd_editor_scroll_roprevline
xEditor      Control         D1              ttcmd_desk_works_focus_work1
xEditor      Control         D2              ttcmd_desk_works_focus_work2
xEditor      Control         D3              ttcmd_desk_works_focus_work3
xEditor      Control         Space           ttcmd_editor_tag_invoke
xEditor      Control         OemPlus         ttcmd_editor_edit_turn_bullet_norm
xEditor      Control         Back            ttcmd_editor_history_previous_tocurrenteditor
xEditor      Control         I               ttcmd_editor_outline_insert_section
xEditor      Control         H               ttcmd_editor_edit_backspace
xEditor      Control         D               ttcmd_editor_edit_delete
xEditor      Control         S               ttcmd_editor_save
xEditor      Control         G               ttcmd_editor_new_tocurrenteditor
xEditor      Control         OemBackslash    ttcmd_application_config_editor_wordwrap_toggle
xEditor      Control         Oem3            ttcmd_application_config_editor_staycursor_toggle
xEditor      Control, Shift  OemPlus         ttcmd_editor_edit_turn_bullet_rev
xEditor      Control, Shift  Back            ttcmd_editor_history_next_tocurrenteditor
xEditor      Control, Shift  A               ttcmd_editor_select_tolinestart
xEditor      Control, Shift  E               ttcmd_editor_select_tolineend
xEditor      Control, Shift  P               ttcmd_editor_select_toprevline
xEditor      Control, Shift  N               ttcmd_editor_select_tonextline
xEditor      Control, Shift  B               ttcmd_editor_select_toleftchar
xEditor      Control, Shift  F               ttcmd_editor_select_torightchar
'@

#region _editor_move/delete_
function ttcmd_editor_move_toprevline( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを前行へ移動する

    $global:appcon.tools.editor.move_to( 'prevline' )
}
function ttcmd_editor_move_tonextline( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを次行へ移動する

    $global:appcon.tools.editor.move_to( 'nextline' )
}
function ttcmd_editor_move_leftchar( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを左へ移動する

    $global:appcon.tools.editor.move_to( 'leftchar' )
}
function ttcmd_editor_move_rightchar( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを右へ移動する

    $global:appcon.tools.editor.move_to( 'rightchar' )
}
function ttcmd_editor_move_tolinestart( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを行頭/文頭へ移動する

    $global:appcon.tools.editor.move_to( 'linestart+' )
}
function ttcmd_editor_move_tolineend( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを行末/文末へ移動する

    $global:appcon.tools.editor.move_to( 'lineend+' )
}
function ttcmd_editor_delete_tolineend( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルから行末までを削除する

    $global:appcon.tools.editor.select_to( 'lineend', 'cut' )
}
function ttcmd_editor_move_toprevkeyword( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを前のキーワードに移動する

    $global:appcon.tools.editor.move_to('prevkeyword')
}
function ttcmd_editor_move_tonextkeyword( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを次のキーワードに移動する

    $global:appcon.tools.editor.move_to('nextkeyword')
}

#endregion

#region _outline_moveto/fold/collapse_
function ttcmd_editor_outline_moveto_next( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを次ののセクションに移動する

    $global:appcon.tools.editor.move_to('nextnode')
}
function ttcmd_editor_outline_moveto_previous( $source, $mod, $key ){
    #.SYNOPSIS
    # カーソルを前のセクションへ移動する

    $global:appcon.tools.editor.move_to('prevnode')
}
function ttcmd_editor_outline_fold_section( $source, $mod, $key ){

    #.SYNOPSIS
    # セクションを折り畳む

    $global:appcon.tools.editor.node_to('close')
}
function ttcmd_editor_outline_collapse_section( $source, $mod, $key ){
    #.SYNOPSIS
    # セクションを展開する

    $global:appcon.tools.editor.node_to('open')
}

#endregion

#endregion###############################################################################################################


#region Cabinet
#########################################################################################################################
$global:KeyBind_Cabinet = @'
Cabinet         Alt             P           ttcmd_panel_move_up
Cabinet         Alt             N           ttcmd_panel_move_down
Cabinet         Alt, Shift      P           ttcmd_panel_move_first
Cabinet         Alt, Shift      N           ttcmd_panel_move_last
Cabinet         None            Up          ttcmd_panel_move_up
Cabinet         None            Down        ttcmd_panel_move_down
Cabinet         Shift           Up          ttcmd_panel_move_first
Cabinet         Shift           Down        ttcmd_panel_move_last
Cabinet         Ctrl            D           ttcmd_panel_discard_selected
Cabinet         Alt             Escape      ttcmd_panel_collapse_cabinet
Cabinet         None            Escape      ttcmd_panel_collapse_cabinet
Cabinet         Alt             D0          ttcmd_panel_reload
Cabinet         Alt             K           ttcmd_panel_filter_clear
Cabinet         Alt             Space       ttcmd_panel_action_select
Cabinet         Alt, Shift      Space       ttcmd_panel_action_invoke
Cabinet         None            Return      ttcmd_panel_action_select
Cabinet         Shift           Return      ttcmd_panel_action_invoke
'@

#endregion###############################################################################################################


#region PopupMenu
#########################################################################################################################
$global:KeyBind_PopupMenu = @'
PopupMenu   Alt             P           ttcmd_menu_move_up
PopupMenu   Alt             N           ttcmd_menu_move_down
PopupMenu   None            Up          ttcmd_menu_move_up
PopupMenu   None            Down        ttcmd_menu_move_down
PopupMenu   Alt, Shift      P           ttcmd_menu_move_first
PopupMenu   Alt, Shift      N           ttcmd_menu_move_last
PopupMenu   Shift           Up          ttcmd_menu_move_first
PopupMenu   Shift           Down        ttcmd_menu_move_last
popupMenu   Alt             Escape      ttcmd_menu_cancel
PopupMenu   None            Escape      ttcmd_menu_cancel
PopupMenu   Alt             Return      ttcmd_menu_ok
PopupMenu   Alt             Space       ttcmd_menu_ok
PopupMenu   None            Return      ttcmd_menu_ok
'@

#endregion###############################################################################################################