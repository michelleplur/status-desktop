type
  WrongPasswordState* = ref object of State
    success: bool

proc newWrongPasswordState*(flowType: FlowType, backState: State): WrongPasswordState =
  result = WrongPasswordState()
  result.setup(flowType, StateType.WrongPassword, backState)
  result.success = false

proc delete*(self: WrongPasswordState) =
  self.State.delete

method executePrimaryCommand*(self: WrongPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setKeycardData("")
    let password = controller.getPassword()
    self.success = controller.verifyPassword(password)
    if self.success:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    else:
      controller.setKeycardData("wrong-pass")

method executeSecondaryCommand*(self: WrongPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.tryToObtainDataFromKeychain()

method executeTertiaryCommand*(self: WrongPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)