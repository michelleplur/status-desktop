from scripts.global_names import *

# Main:
loginView_passwordInput = {"container": statusDesktop_mainWindow, "objectName": "loginPasswordInput", "type": "StyledTextField"}
loginView_changeAccountBtn = {"container": statusDesktop_mainWindow, "objectName": "loginChangeAccountButton", "type": "StatusFlatRoundButton"}
loginView_currentUserNameLabel = {"container": statusDesktop_mainWindow, "objectName": "currentUserNameLabel", "type": "StatusBaseText"}
loginView_submitBtn = {"container": statusDesktop_mainWindow, "type": "StatusRoundButton", "visible": True}
loginView_main = {"container": statusDesktop_mainWindow, "type": "LoginView", "visible": True}
loginView_errMsgLabel = {"container": statusDesktop_mainWindow, "objectName": "loginPassworkInputValidationErrorText", "type": "StatusBaseText", "visible": True}
accountsView_accountListPanel = {"container": statusDesktop_mainWindow, "type": "ListView", "visible": True} # This probably is missing an objectName
loginView_userImage = {"container": statusDesktop_mainWindow, "objectName": "loginViewUserImage", "type": "UserImage", "visible": True}
