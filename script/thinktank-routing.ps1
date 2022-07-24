﻿




#region  View Events Binding
[ScriptBlock] $global:TTWindowLoaded =  { $args[1].Handled = $global:appcon.initialize_application() }

[ScriptBlock] $global:TTPanel_GotFocus =    { $args[1].Handled = $global:appcon.event_set_focus_panel( $args ) }
[ScriptBlock] $global:TTTextBox_GotFocus =  { $args[1].Handled = $global:appcon.event_set_focus_application( $args ) }
[ScriptBlock] $global:TTTool_GotFocus =     { $args[1].Handled = $global:appcon.event_set_focus_application( $args ) }
[ScriptBlock] $global:TTDataGrid_GotFocus = { $args[1].Handled = $global:appcon.event_refocus( $args ) }

[ScriptBlock] $global:TTAppMan_PreviewKeyDown = $global:TTPreviewKeyDown
[ScriptBlock] $global:TTCabin_PreviewKeyDown =  $global:TTPreviewKeyDown
[ScriptBlock] $global:TTPopup_PreviewKeyDown =  $global:TTPreviewKeyDown
[ScriptBlock] $global:TTPanel_PreviewKeyDown =  {}
[ScriptBlock] $global:TTTool_PreviewKeyDown =   {}

[ScriptBlock] $global:TTWindow_PreviewKeyUp =   $global:TTPreviewKeyUp
[ScriptBlock] $global:TTCabin_PreviewKeyUp =    $global:TTPreviewKeyUp
[ScriptBlock] $global:TTPopup_PreviewKeyUp =    $global:TTPreviewKeyUp
[ScriptBlock] $global:TTPanel_PreviewKeyUp =    {}
[ScriptBlock] $global:TTTool_PreviewKeyUp =     {}

[ScriptBlock] $global:TTDataGrid_PreviewMouseDown =     { $global:appcon.group.event_select_datagrid_item_by_mouse( $args ) }
[ScriptBlock] $global:TextEditors_PreviewMouseDown =    { $global:appcon.tools.editor.on_previewmousedown( $args ) }


[ScriptBlock] $global:TTPanel_SizeChanged = { $global:appcon.event_set_border( $args ) }

# [ScriptBlock] $global:TTPanelTool_GotFocus =    { $args[1].Handled = $global:appcon.set_gotfocus_status( $args ) }
# [ScriptBlock] $global:TTPanelTool_LostFocus =   { $args[1].Handled = $global:appcon.set_lostfocus_status( $args ) }

[ScriptBlock] $global:TTPanel_TextChanged_ToExtract =   { $global:appcon.group.event_extract_datagrid_items( $args ) }
[ScriptBlock] $global:TTDesk_TextChanged_ToHighlight =  { $global:appcon.group.event_highlight_text_on_editor( $args ) }

[ScriptBlock] $global:TTDataGrid_Sorting =          { $global:appcon.group.event_sort_datagrid( $args ) }
[ScriptBlock] $global:TTDataGrid_SelectionChanged = { $global:appcon.group.event_selection_change_datagrid( $args ) }

[ScriptBlock] $global:TextEditors_TextChanged =        { $global:appcon.tools.editor.on_textchanged( $args ) }
[ScriptBlock] $global:TextEditors_GotFocus =           { $global:appcon.tools.editor.on_focus( $args ) }
[ScriptBlock] $global:TextEditors_PreviewDrop =        { $global:appcon.tools.editor.on_previewdrop( $args ) }

[ScriptBlock] $global:TTMenu_GotFocus = {}     # menu制御
[ScriptBlock] $global:TTMenu_LostFocus = {}
[ScriptBlock] $global:TTWindow_GotFocus = {}   # application制御
[ScriptBlock] $global:TTWindow_LostFocus = {}


[ScriptBlock] [TTEditorsManager]::OnSave = { $global:appcon.tools.editor.on_save( $args ) }
[ScriptBlock] [TTEditorsManager]::OnLoad = { $global:appcon.tools.editor.on_load( $args ) }

#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


#region　Model Action-Command Binding
[TTCollection]::Action =                    'ttact_display_in_shelf'
[TTCollection]::ActionDiscardResources =    'ttact_discard_resources'
[TTCollection]::ActionToShelf =             'ttact_display_in_shelf'
[TTCollection]::ActionToIndex =             'ttact_display_in_index'
[TTCollection]::ActionToCabinet =           'ttact_display_in_cabinet'
[TTCollection]::ActionDataLocaiton =        'ttact_select_file'
[TTConfig]::Action =                    'ttact_noop'
[TTConfig]::ActionDiscardResources =    'ttact_noop'
[TTConfig]::ActionDataLocaiton =        'ttact_noop'
[TTState]::Action =                     'ttact_noop'
[TTState]::ActionDiscardResources =     'ttact_noop'
[TTState]::ActionFilter =               'ttact_noop'
[TTCommand]::Action =                   'ttact_noop'
[TTCommand]::ActionDiscardResources =   'ttact_noop'
[TTCommand]::ActionInvokeCommand =      'ttact_noop'
[TTSearchMethod]::Action =                  'ttact_noop'
[TTSearchMethod]::ActionDiscardResources =  'ttact_noop'
[TTSearchMethod]::ActionDataLocation =      'ttact_noop'
[TTSearchMethod]::ActionToEditor =          'ttact_noop'
[TTSearchMethod]::ActionOpenUrl =           'ttact_open_url'
[TTSearchMethod]::ActionOpenUrlEx =         'ttact_open_url_ex'
[TTSearchMethod]::ActionToClipboard =       'ttact_copy_url_toclipboard'
[TTExternalLink]::Action =                  'ttact_noop'
[TTExternalLink]::ActionDiscardResources =  'ttact_noop'
[TTExternalLink]::ActionDataLocation =      'ttact_noop'
[TTExternalLink]::ActionOpenUrl =           'ttact_open_url'
[TTExternalLink]::ActionOpenUrlEx =         'ttact_open_url_ex'
[TTExternalLink]::ActionToClipboard =       'ttact_copy_url_toclipboard'
[TTMemo]::Action =                  'ttact_open_memo'
[TTMemo]::ActionDiscardResources =  'ttact_discard_resources'
[TTMemo]::ActionOpen =              'ttact_open_memo'
[TTMemo]::ActionDataLocation =      'ttact_select_file'
[TTMemo]::ActionToClipboard =       'ttact_noop'
[TTEditing]::Action =                  'ttact_open_memo'
[TTEditing]::ActionDiscardResources =  'ttact_discard_resources'
[TTEditing]::ActionDataLocation =      'ttact_select_file'

#endregion'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

#region　Model Events Binding
[ScriptBlock] $global:TTStatus_OnSave = {  $global:appcon.event_save_status( $args ) } 
#endregion:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::


#region　View Key-Command Binding 
#'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
#　oem1 = semicolon [;]
#　
$global:KeyBind_Misc = @'
xShelf       Shift       Return      ttcmd_shelf_activate_item
xShelf       Alt         Up          ttcmd_application_border_inworkplace_up
xShelf       Alt         Down        ttcmd_application_border_inworkplace_down
xShelf       Alt         Left        ttcmd_application_border_inwpanel_left
xShelf       Alt         Right       ttcmd_application_border_inwpanel_right
xShelf       Alt         D1          ttcmd_shelf_selected_toeditor1
xShelf       Alt         D2          ttcmd_shelf_selected_toeditor2
xShelf       Alt         D3          ttcmd_shelf_selected_toeditor3
xShelf       Alt         M           ttcmd_shelf_focus_menu
xShelf       Control     C           ttcmd_shelf_copy_item
xIndex       Alt         D1          ttcmd_shelf_selected_toeditor1
xIndex       Alt         D2          ttcmd_shelf_selected_toeditor2
xIndex       Alt         D3          ttcmd_shelf_selected_toeditor3
xIndex       Control     C           ttcmd_shelf_copy_item; break Handled
'@

#endregion






