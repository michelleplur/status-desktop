type
  LoginState* = ref object of State

proc newLoginState*(flowType: FlowType, backState: State): LoginState =
  result = LoginState()
  result.setup(flowType, StateType.Login, backState)

proc delete*(self: LoginState) =
  self.State.delete

method executePrimaryCommand*(self: LoginState, controller: Controller) =
  if self.flowType == FlowType.AppLogin:
    if not controller.isSelectedLoginAccountKeycardAccount():
      controller.login()
    elif not controller.keychainErrorOccurred() and controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())

method getNextPrimaryState*(self: LoginState, controller: Controller): State =
  if controller.keychainErrorOccurred():
    return createState(StateType.LoginKeycardEnterPin, self.flowType, nil)

method getNextSecondaryState*(self: LoginState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeNewStatusUser, self.flowType, self)

method getNextTertiaryState*(self: LoginState, controller: Controller): State =
  controller.cancelCurrentFlow()
  return createState(StateType.WelcomeOldStatusUser, self.flowType, self)

method resolveKeycardNextState*(self: LoginState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  return ensureReaderAndCardPresenceAndResolveNextLoginState(self, keycardFlowType, keycardEvent, controller)