package com.bro.brocast.keyboards

class BromojiList {

    // We hardcoded the categories. These are the categories that will be used.
    var bromojiFirstKeyboard: ArrayList<String> = ArrayList()
    var bromojiPeople: ArrayList<String> = ArrayList()
    var bromojiAnimals: ArrayList<String> = ArrayList()
    var bromojiFood: ArrayList<String> = ArrayList()
    var bromojiSports: ArrayList<String> = ArrayList()
    var bromojiTravel: ArrayList<String> = ArrayList()
    var bromojiObjects: ArrayList<String> = ArrayList()
    var bromojiSymbols: ArrayList<String> = ArrayList()
    var bromojiFlags: ArrayList<String> = ArrayList()

    var bromojiFirstKeyboard2: ArrayList<Bromoji> = ArrayList()
    var bromojiPeople2: ArrayList<Bromoji> = ArrayList()
    var bromojiAnimals2: ArrayList<Bromoji> = ArrayList()
    var bromojiFood2: ArrayList<Bromoji> = ArrayList()
    var bromojiSports2: ArrayList<Bromoji> = ArrayList()
    var bromojiTravel2: ArrayList<Bromoji> = ArrayList()
    var bromojiObjects2: ArrayList<Bromoji> = ArrayList()
    var bromojiSymbols2: ArrayList<Bromoji> = ArrayList()
    var bromojiFlags2: ArrayList<Bromoji> = ArrayList()

    fun addMostUsed(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFirstKeyboard.add(char)
        bromojiFirstKeyboard2.add(b)
    }

    fun addPeopleCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiPeople.add(char)
        bromojiPeople2.add(b)
    }

    fun addAnimalsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiAnimals.add(char)
        bromojiAnimals2.add(b)
    }

    fun addFoodCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFood.add(char)
        bromojiFood2.add(b)
    }

    fun addSportsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiSports.add(char)
        bromojiSports2.add(b)
    }

    fun addTravelCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiTravel.add(char)
        bromojiTravel2.add(b)
    }

    fun addObjectsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiObjects.add(char)
        bromojiObjects2.add(b)
    }

    fun addSymbolsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiSymbols.add(char)
        bromojiSymbols2.add(b)
    }

    fun addFlagsCategory(codes: Array<String>, char: String, name: String, category: String) {
        val b = Bromoji(codes, char, name, category)
        bromojiFlags.add(char)
        bromojiFlags2.add(b)
    }
}
