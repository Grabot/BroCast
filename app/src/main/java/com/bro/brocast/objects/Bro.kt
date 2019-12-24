package com.bro.brocast.objects

class Bro(
    var broName: String,
    var id: Int,
    var bromotion: String
) {

    var messageCount: Int = 0
    var lastMessageTime: Double = 0.0

    fun getFullBroName(): String {
        return "$broName $bromotion"
    }

    fun setNewMessage(messageCount: Int) {
        this.messageCount = messageCount
    }

    fun getNewMessages(): Int {
        return this.messageCount
    }

    fun setLastMessage(lastMessageTime: Double) {
        this.lastMessageTime = lastMessageTime
    }

    fun getLastMessage(): Double {
        return this.lastMessageTime
    }
}