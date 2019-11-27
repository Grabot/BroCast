package com.bro.brocast.objects

class Bro(
    private var username: String,
    private var id: Int
) {

    fun setUsername(username: String) {
        this.username = username
    }

    fun getUsername(): String {
        return this.username
    }

    fun setId(id: Int) {
        this.id = id
    }

    fun getId(): Int {
        return this.id
    }
}