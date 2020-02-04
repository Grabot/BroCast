package com.bro.brocast.keyboards

class BromojiList {

    // We hardcoded the categories. These are the categories that will be used.
    var bromojiFirstKeyboard: ArrayList<Bromoji> = ArrayList()
    var bromojiPeople: ArrayList<Bromoji> = ArrayList()
    var bromojiAnimals: ArrayList<Bromoji> = ArrayList()
    var bromojiFood: ArrayList<Bromoji> = ArrayList()
    var bromojiSports: ArrayList<Bromoji> = ArrayList()
    var bromojiTravel: ArrayList<Bromoji> = ArrayList()
    var bromojiObjects: ArrayList<Bromoji> = ArrayList()
    var bromojiSymbols: ArrayList<Bromoji> = ArrayList()
    var bromojiFlags: ArrayList<Bromoji> = ArrayList()

    fun addMostUsed(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFirstKeyboard.add(b)
    }

    fun addPeopleCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiPeople.add(b)
    }

    fun addAnimalsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiAnimals.add(b)
    }

    fun addFoodCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFood.add(b)
    }

    fun addSportsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiSports.add(b)
    }

    fun addTravelCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiTravel.add(b)
    }

    fun addObjectsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiObjects.add(b)
    }

    fun addSymbolsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiSymbols.add(b)
    }

    fun addFlagsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFlags.add(b)
    }
}
