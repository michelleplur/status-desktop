type
  WrongBiometricsPasswordState* = ref object of State
    success: bool

proc newWrongBiometricsPasswordState*(flowType: FlowType, backState: State): WrongBiometricsPasswordState =
  result = WrongBiometricsPasswordState()
  result.setup(flowType, StateType.WrongBiometricsPassword, backState)
  result.success = false

proc delete*(self: WrongBiometricsPasswordState) =
  self.State.delete

method executePrimaryCommand*(self: WrongBiometricsPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setKeycardData("")
    let password = controller.getPassword()
    self.success = controller.verifyPassword(password)
    if self.success:
      controller.tryToStoreDataToKeychain(password)
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    else:
      controller.setKeycardData("wrong-pass")

method executeTertiaryCommand*(self: WrongBiometricsPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)