package com.bro.brocast.keyboards

class BromojiList {

    // We hardcoded the categories. These are the categories that will be used.
    var bromojiFirstKeyboard: ArrayList<String> = ArrayList()
    var bromojiPeople: ArrayList<String> = ArrayList()
    var bromojiPeople2: ArrayList<Bromoji> = ArrayList()
    var bromojiAnimals: ArrayList<String> = ArrayList()
    var bromojiFood: ArrayList<String> = ArrayList()
    var bromojiSports: ArrayList<String> = ArrayList()
    var bromojiTravel: ArrayList<String> = ArrayList()
    var bromojiObjects: ArrayList<String> = ArrayList()
    var bromojiSymbols: ArrayList<String> = ArrayList()
    var bromojiFlags: ArrayList<String> = ArrayList()

    fun addPeopleCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiPeople.add(char)
        bromojiPeople2.add(b)
    }

    fun addAnimalsCategory(emoji: String) {
        bromojiAnimals.add(emoji)
    }

    fun addFoodCategory(emoji: String) {
        bromojiFood.add(emoji)
    }

    fun addSportsCategory(emoji: String) {
        bromojiSports.add(emoji)
    }

    fun addTravelCategory(emoji: String) {
        bromojiTravel.add(emoji)
    }

    fun addObjectsCategory(emoji: String) {
        bromojiObjects.add(emoji)
    }

    fun addSymbolsCategory(emoji: String) {
        bromojiSymbols.add(emoji)
    }

    fun addFlagsCategory(emoji: String) {
        bromojiFlags.add(emoji)
    }
}
