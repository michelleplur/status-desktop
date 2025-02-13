type
  EnterBiometricsPasswordState* = ref object of State
    success: bool

proc newEnterBiometricsPasswordState*(flowType: FlowType, backState: State): EnterBiometricsPasswordState =
  result = EnterBiometricsPasswordState()
  result.setup(flowType, StateType.EnterBiometricsPassword, backState)
  result.success = false

proc delete*(self: EnterBiometricsPasswordState) =
  self.State.delete

method executePrimaryCommand*(self: EnterBiometricsPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    let password = controller.getPassword()
    self.success = controller.verifyPassword(password)
    if self.success:
      controller.tryToStoreDataToKeychain(password)
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = true)
    else:
      controller.setKeycardData("wrong-pass")

method getNextPrimaryState*(self: EnterBiometricsPasswordState, controller: Controller): State =
  if self.flowType == FlowType.Authentication:
    if not self.success:
      return createState(StateType.WrongBiometricsPassword, self.flowType, nil)

method executeTertiaryCommand*(self: EnterBiometricsPasswordState, controller: Controller) =
  if self.flowType == FlowType.Authentication:
    controller.setPassword("")
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)