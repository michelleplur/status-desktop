type
  KeycardCreatePinState* = ref object of State
    pinValid: bool 

proc newKeycardCreatePinState*(flowType: FlowType, backState: State): KeycardCreatePinState =
  result = KeycardCreatePinState()
  result.setup(flowType, StateType.KeycardCreatePin, backState)
  result.pinValid = false

proc delete*(self: KeycardCreatePinState) =
  self.State.delete

method executeBackCommand*(self: KeycardCreatePinState, controller: Controller) =
  controller.setPin("")
  controller.setPinMatch(false)

method getNextPrimaryState*(self: KeycardCreatePinState, controller: Controller): State =
  if not self.pinValid:
    return nil
  return createState(StateType.KeycardRepeatPin, self.flowType, self.getBackState)

method executePrimaryCommand*(self: KeycardCreatePinState, controller: Controller) =
  self.pinValid = controller.getPin().len == PINLengthForStatusApp