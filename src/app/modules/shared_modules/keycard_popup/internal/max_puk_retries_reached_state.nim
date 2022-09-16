type
  MaxPukRetriesReachedState* = ref object of State

proc newMaxPukRetriesReachedState*(flowType: FlowType, backState: State): MaxPukRetriesReachedState =
  result = MaxPukRetriesReachedState()
  result.setup(flowType, StateType.MaxPukRetriesReached, backState)

proc delete*(self: MaxPukRetriesReachedState) =
  self.State.delete

method getNextPrimaryState*(self: MaxPukRetriesReachedState, controller: Controller): State =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard:
      return createState(StateType.FactoryResetConfirmation, self.flowType, self)
  if self.flowType == FlowType.Authentication:
      debug "Run Unlock Keycard flow... (not developed yet)"
  if self.flowType == FlowType.UnlockKeycard:
    return createState(StateType.EnterSeedPhrase, self.flowType, self)

method executeTertiaryCommand*(self: MaxPukRetriesReachedState, controller: Controller) =
  if self.flowType == FlowType.FactoryReset or
    self.flowType == FlowType.SetupNewKeycard or
    self.flowType == FlowType.Authentication or
    self.flowType == FlowType.UnlockKeycard:
      controller.terminateCurrentFlow(lastStepInTheCurrentFlow = false)