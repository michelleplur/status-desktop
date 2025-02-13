type
  WrongPinState* = ref object of State

proc newWrongPinState*(flowType: FlowType, backState: State): WrongPinState =
  result = WrongPinState()
  result.setup(flowType, StateType.WrongPin, backState)

proc delete*(self: WrongPinState) =
  self.State.delete

method getNextPrimaryState*(self: WrongPinState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication:
    if controller.getPin().len == PINLengthForStatusApp:
      controller.enterKeycardPin(controller.getPin())
  return nil

method executeSecondaryCommand*(self: WrongPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      if controller.getPin().len == PINLengthForStatusApp:
        controller.enterKeycardPin(controller.getPin())  
  if self.flowType == FlowType.Authentication:
    controller.setUsePinFromBiometrics(false)
    controller.tryToObtainDataFromKeychain()

method executeTertiaryCommand*(self: WrongPinState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)

method resolveKeycardNextState*(self: WrongPinState, keycardFlowType: string, keycardEvent: KeycardEvent, 
  controller: Controller): State =
  let state = ensureReaderAndCardPresence(self, keycardFlowType, keycardEvent, controller)
  if not state.isNil:
    return state
  if self.flowType == FlowType.FactoryReset:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.SetupNewKeycard:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
        controller.setKeycardData($keycardEvent.pinRetries)
        if keycardEvent.pinRetries > 0:
          return self
        return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      controller.setMetadataFromKeycard(keycardEvent.cardMetadata)
      return createState(StateType.PinVerified, self.flowType, nil)
  if self.flowType == FlowType.Authentication:
    if keycardFlowType == ResponseTypeValueEnterPIN and 
      keycardEvent.error.len > 0 and
      keycardEvent.error == ErrorPIN:
      controller.setKeycardData($keycardEvent.pinRetries)
      if keycardEvent.pinRetries > 0:
        return self
      return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueEnterPUK and 
      keycardEvent.error.len == 0:
        if keycardEvent.pinRetries == 0 and keycardEvent.pukRetries > 0:
          return createState(StateType.MaxPinRetriesReached, self.flowType, nil)
    if keycardFlowType == ResponseTypeValueKeycardFlowResult:
      if keycardEvent.error.len == 0:
        controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
        return nil