import Nimqml, json, strformat

QtObject:
  type
    DiscordMessageAuthorItem* = ref object of QObject
      id: string
      name: string
      discriminator: string
      nickname*: string
      avatarUrl*: string

  proc setup(self: DiscordMessageAuthorItem) =
    self.QObject.setup

  proc delete*(self: DiscordMessageAuthorItem) =
    self.QObject.delete

  proc newDiscordMessageAuthorItem*(
      id: string,
      name: string,
      discriminator: string,
      nickname: string,
      avatarUrl: string
      ): DiscordMessageAuthorItem =
    new(result, delete)
    result.setup
    result.id = id
    result.name = name
    result.discriminator = discriminator
    result.nickname = nickname
    result.avatarUrl = avatarUrl

  proc `$`*(self: DiscordMessageAuthorItem): string =
    result = fmt"""DiscordMessageAuthorItem(
      id: {$self.id},
      name: {$self.name},
      discriminator: {$self.discriminator},
      nickname: {$self.nickname},
      avatarUrl: {$self.avatarUrl},
      )"""

  proc id*(self: DiscordMessageAuthorItem): string {.inline.} =
    self.id

  proc idChanged*(self: DiscordMessageAuthorItem) {.signal.}

  QtProperty[string] id:
    read = id
    notify = idChanged

  proc name*(self: DiscordMessageAuthorItem): string {.inline.} =
    self.name

  proc nameChanged*(self: DiscordMessageAuthorItem) {.signal.}

  QtProperty[string] name:
    read = name
    notify = nameChanged

  proc discriminator*(self: DiscordMessageAuthorItem): string {.inline.} =
    self.discriminator

  proc discriminatorChanged*(self: DiscordMessageAuthorItem) {.signal.}

  QtProperty[string] discriminator:
    read = discriminator
    notify = discriminatorChanged

  proc nickname*(self: DiscordMessageAuthorItem): string {.inline.} =
    self.nickname

  proc nicknameChanged*(self: DiscordMessageAuthorItem) {.signal.}

  QtProperty[string] nickname:
    read = nickname
    notify = nicknameChanged

  proc avatarUrl*(self: DiscordMessageAuthorItem): string {.inline.} =
    self.avatarUrl

  proc avatarUrlChanged*(self: DiscordMessageAuthorItem) {.signal.}

  QtProperty[string] avatarUrl:
    read = avatarUrl
    notify = avatarUrlChanged
