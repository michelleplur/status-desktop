{.used.}

type SignalType* {.pure.} = enum
  Message = "messages.new"
  Wallet = "wallet"
  NodeReady = "node.ready"
  NodeCrashed = "node.crashed"
  NodeStarted = "node.started"
  NodeStopped = "node.stopped"
  NodeLogin = "node.login"
  EnvelopeSent = "envelope.sent"
  EnvelopeExpired = "envelope.expired"
  MailserverRequestCompleted = "mailserver.request.completed"
  MailserverRequestExpired = "mailserver.request.expired"
  DiscoveryStarted = "discovery.started"
  DiscoveryStopped = "discovery.stopped"
  DiscoverySummary = "discovery.summary"
  SubscriptionsData = "subscriptions.data"
  SubscriptionsError = "subscriptions.error"
  WhisperFilterAdded = "whisper.filter.added"
  CommunityFound = "community.found"
  PeerStats = "wakuv2.peerstats"
  Stats = "stats"
  ChroniclesLogs = "chronicles-log"
  HistoryRequestStarted = "history.request.started"
  HistoryRequestCompleted = "history.request.completed"
  HistoryRequestFailed = "history.request.failed"
  HistoryRequestBatchProcessed = "history.request.batch.processed"
  KeycardConnected = "keycard.connected"
  MailserverAvailable = "mailserver.available"
  MailserverChanged = "mailserver.changed"
  MailserverNotWorking = "mailserver.not.working"
  HistoryArchivesProtocolEnabled = "community.historyArchivesProtocolEnabled"
  HistoryArchivesProtocolDisabled = "community.historyArchivesProtocolDisabled"
  CreatingHistoryArchives = "community.creatingHistoryArchives"
  HistoryArchivesCreated = "community.historyArchivesCreated"
  NoHistoryArchivesCreated = "community.noHistoryArchivesCreated"
  HistoryArchivesSeeding = "community.historyArchivesSeeding"
  HistoryArchivesUnseeded = "community.historyArchivesUnseeded"
  HistoryArchiveDownloaded = "community.historyArchiveDownloaded"
  DownloadingHistoryArchivesFinished = "community.downloadingHistoryArchivesFinished"
  UpdateAvailable = "update.available"
  DiscordCategoriesAndChannelsExtracted = "community.discordCategoriesAndChannelsExtracted"
  StatusUpdatesTimedout = "status.updates.timedout"
  DiscordCommunityImportFinished = "community.discordCommunityImportFinished"
  DiscordCommunityImportProgress = "community.discordCommunityImportProgress"
  Unknown

proc event*(self:SignalType):string =
  result = "signal:" & $self
