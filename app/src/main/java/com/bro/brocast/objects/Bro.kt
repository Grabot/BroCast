package com.bro.brocast.objects

class Bro(
    var broName: String,
    var id: Int,
    var bromotion: String
) {
    fun getFullBroName(): String {
        return "$broName $bromotion"
    }
}