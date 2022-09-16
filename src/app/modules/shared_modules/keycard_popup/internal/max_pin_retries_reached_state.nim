type
  MaxPinRetriesReachedState* = ref object of State

proc newMaxPinRetriesReachedState*(flowType: FlowType, backState: State): MaxPinRetriesReachedState =
  result = MaxPinRetriesReachedState()
  result.setup(flowType, StateType.MaxPinRetriesReached, backState)

proc delete*(self: MaxPinRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: MaxPinRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset:
    return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.SetupNewKeycard:
    let currValue = extractPredefinedKeycardDataToNumber(controller.getKeycardData())
    if (currValue and PredefinedKeycardData.UseUnlockLabelForLockedState.int) > 0:
      controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseUnlockLabelForLockedState, add = false))
      debug "Run Unlock Keycard flow... (not developed yet)"
      return nil
    return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication:
      debug "Run Unlock Keycard flow... (not developed yet)"
  return nil

method executeTertiaryCommand*(self: MaxPinRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.Authentication:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)
  if self.flowType == FlowType.SetupNewKeycard:
    controller.setKeycardData(updatePredefinedKeycardData(controller.getKeycardData(), PredefinedKeycardData.UseUnlockLabelForLockedState, add = false))
    controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)