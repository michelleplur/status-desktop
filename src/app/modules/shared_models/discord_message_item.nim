import Nimqml, json, strformat

import discord_message_author_item
import ../../../app_service/service/message/dto/message

QtObject:
  type
    DiscordMessageItem* = ref object of QObject
      id: string
      `type`: string
      timestamp: string
      timestampEdited: string
      content: string
      author: DiscordMessageAuthorItem

  proc setup(self: DiscordMessageItem) =
    self.QObject.setup

  proc delete*(self: DiscordMessageItem) =
    self.QObject.delete

  proc newDiscordMessageItem*(
      id: string,
      `type`: string,
      timestamp: string,
      timestampEdited: string,
      content: string,
      author: DiscordMessageAuthorItem,
      ): DiscordMessageItem =
    new(result, delete)
    result.setup
    result.id = id
    result.type = type
    result.timestamp = timestamp
    result.timestampEdited = timestampEdited
    result.content = content
    result.author = author

  proc `$`*(self: DiscordMessageItem): string =
    result = fmt"""DiscordMessageItem(
      id: {$self.id},
      type: {$self.type},
      timestamp: {$self.timestamp},
      timestampEdited: {$self.timestampEdited},
      content: {$self.content},
      author: {$self.author}
      )"""

  proc idChanged*(self: DiscordMessageItem) {.signal.}

  proc id*(self: DiscordMessageItem): string {.inline.} =
    self.id

  QtProperty[string] id:
    read = id
    notify = idChanged

  proc timestampChanged*(self: DiscordMessageItem) {.signal.}

  proc timestamp*(self: DiscordMessageItem): string {.inline.} =
    self.timestamp

  QtProperty[string] timestamp:
    read = timestamp
    notify = timestampChanged

  proc timestampEditedChanged*(self: DiscordMessageItem) {.signal.}

  proc timestampEdited*(self: DiscordMessageItem): string {.inline.} =
    self.timestampEdited

  QtProperty[string] timestampEdited:
    read = timestampEdited
    notify = timestampEditedChanged

  proc contentChanged*(self: DiscordMessageItem) {.signal.}

  proc content*(self: DiscordMessageItem): string {.inline.} =
    self.content

  QtProperty[string] content:
    read = content
    notify = contentChanged

  proc authorChanged*(self: DiscordMessageItem) {.signal.}
  proc author*(self: DiscordMessageItem): DiscordMessageAuthorItem {.inline.} =
    self.author

  QtProperty[string] author:
    read = author
    notify = authorChanged
