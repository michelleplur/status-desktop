type
  KeyDetails* = object
    address*: string
    publicKey*: string
    privateKey*: string 

  KeycardEvent* = object
    error*: string
    seedPhraseIndexes*: seq[int]
    freePairingSlots*: int
    keyUid*: string
    pinRetries*: int
    pukRetries*: int
    eip1581Key*: KeyDetails
    encryptionKey*: KeyDetails
    masterKey*: KeyDetails
    walletKey*: KeyDetails
    walletRootKey*: KeyDetails
    whisperKey*: KeyDetails

proc toKeyDetails(jsonObj: JsonNode): KeyDetails =
  discard jsonObj.getProp(RequestParamAddress, result.address)
  discard jsonObj.getProp(RequestParamPrivateKey, result.privateKey)
  if jsonObj.getProp(RequestParamPublicKey, result.publicKey):
    result.publicKey = "0x" & result.publicKey

proc toKeycardEvent(jsonObj: JsonNode): KeycardEvent =
  discard jsonObj.getProp(ErrorKey, result.error)
  discard jsonObj.getProp(RequestParamFreeSlots, result.freePairingSlots)
  discard jsonObj.getProp(RequestParamKeyUID, result.keyUid)
  discard jsonObj.getProp(RequestParamPINRetries, result.pinRetries)
  discard jsonObj.getProp(RequestParamPUKRetries, result.pukRetries)

  var obj: JsonNode
  if(jsonObj.getProp(RequestParamEncKey, obj)):
    result.eip1581Key = toKeyDetails(obj)

  if(jsonObj.getProp(RequestParamEncKey, obj)):
    result.encryptionKey = toKeyDetails(obj)

  if(jsonObj.getProp(RequestParamEncKey, obj)):
    result.masterKey = toKeyDetails(obj)

  if(jsonObj.getProp(RequestParamEncKey, obj)):
    result.walletKey = toKeyDetails(obj)

  if(jsonObj.getProp(RequestParamEncKey, obj)):
    result.walletRootKey = toKeyDetails(obj)

  if(jsonObj.getProp(RequestParamWhisperKey, obj)):
    result.whisperKey = toKeyDetails(obj)

  var indexesArr: JsonNode
  if jsonObj.getProp(RequestParamMnemonicIdxs, indexesArr) and indexesArr.kind == JArray:
    for ind in indexesArr:
      result.seedPhraseIndexes.add(ind.getInt)