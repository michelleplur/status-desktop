
statusDesktop_mainWindow = {"name": "mainWindow", "type": "StatusWindow", "visible": True}
statusDesktop_mainWindow_overlay = {"container": statusDesktop_mainWindow, "type": "Overlay", "unnamed": 1, "visible": True}
mainWindow_navBarListView_ListView = {"container": statusDesktop_mainWindow, "objectName": "statusMainNavBarListView", "type": "ListView", "visible": True}
chatView_log = {"container": statusDesktop_mainWindow, "objectName": "chatLogView", "type": "StatusListView", "visible": True}
chatMessageListView_msgDelegate_MessageView = {"container": chatView_log, "objectName": "chatMessageViewDelegate", "index": 1, "type": "MessageView", "visible": True}
moduleWarning_Banner = {"container": statusDesktop_mainWindow, "objectName": "moduleWarningBanner", "type": "ModuleWarning", "visible": True}
statusDesktop_mainWindow_AppMain_EmojiPopup_SearchTextInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "StatusEmojiPopup_searchBox", "type": "TextEdit", "visible": True}
mainWindow_ScrollView = {"container": statusDesktop_mainWindow, "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_ScrollView_2 = {"container": statusDesktop_mainWindow, "occurrence": 2, "type": "StatusScrollView", "unnamed": 1, "visible": True}
mainWindow_ProfileNavBarButton = {"container": statusDesktop_mainWindow, "objectName": "statusProfileNavBarTabButton", "type": "StatusNavBarTabButton", "visible": True}
settings_navbar_settings_icon_StatusIcon = {"container": mainWindow_navBarListView_ListView, "objectName": "settings-icon", "type": "StatusIcon", "visible": True}

# main right panel
mainWindow_RighPanel= {"container": statusDesktop_mainWindow, "type": "ColumnLayout", "objectName": "mainRightView", "visible": True}

# User Status Profile Menu
userContextmenu_AlwaysActiveButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuAlwaysOnlineAction", "type": "StatusMenuItemDelegate", "visible": True}
userContextmenu_InActiveButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuInactiveAction", "type": "StatusMenuItemDelegate", "visible": True}
userContextmenu_AutomaticButton= {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusMenuAutomaticAction", "type": "StatusMenuItemDelegate", "visible": True}
userContextMenu_ViewMyProfileAction = {"container": statusDesktop_mainWindow_overlay, "objectName": "userStatusViewMyProfileAction", "type": "StatusMenuItemDelegate", "visible": True}

# popups
modal_Close_Button = {"container": statusDesktop_mainWindow_overlay, "objectName": "modalCloseButtonRectangle", "type": "Rectangle", "visible": True}

# Main Window - chat related:
mainWindow_public_chat_icon_StatusIcon = {"container": statusDesktop_mainWindow, "objectName": "public-chat-icon", "source": "qrc:/StatusQ/src/assets/img/icons/public-chat.svg", "type": "StatusIcon", "visible": True}
chatList_Repeater = {"container": statusDesktop_mainWindow, "objectName": "chatListItems", "type": "Repeater"}
chatList = {"container": statusDesktop_mainWindow, "objectName": "ContactsColumnView_chatList", "type": "StatusChatList"}
mainWindow_startChat = {"checkable": True, "container": statusDesktop_mainWindow, "objectName": "startChatButton", "type": "StatusIconTabButton"}
join_public_chat_StatusMenuItemDelegate = {"checkable": False, "container": statusDesktop_mainWindow_overlay, "enabled": True, "text": "Join public chat", "type": "StatusMenuItemDelegate", "unnamed": 1, "visible": True}

# My Profile Popup
ProfileHeader_userImage = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileHeader_userImage", "type": "UserImage", "visible": True}
ProfileHeader_displayName = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileHeader_displayName", "type": "StyledText", "visible": True}
ProfileHeader_displayNameEditIcon = {"container": statusDesktop_mainWindow_overlay, "objectName": "ProfileHeader_displayNameEditIcon", "type": "SVGImage", "visible": True}
DisplayNamePopup_displayNameInput = {"container": statusDesktop_mainWindow_overlay, "objectName": "DisplayNamePopup_displayNameInput", "type": "TextEdit", "visible": True}
DisplayNamePopup_okButton = {"container": statusDesktop_mainWindow_overlay, "objectName": "DisplayNamePopup_okButton", "type": "StatusButton", "visible": True}

