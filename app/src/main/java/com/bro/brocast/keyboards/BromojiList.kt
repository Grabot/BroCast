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

    fun addMostUsed(b: Bromoji) {
        bromojiFirstKeyboard.add(b)
    }

    fun addPeopleCategory(b: Bromoji) {
        bromojiPeople.add(b)
    }

    fun addAnimalsCategory(b: Bromoji) {
        bromojiAnimals.add(b)
    }

    fun addFoodCategory(b: Bromoji) {
        bromojiFood.add(b)
    }

    fun addSportsCategory(b: Bromoji) {
        bromojiSports.add(b)
    }

    fun addTravelCategory(b: Bromoji) {
        bromojiTravel.add(b)
    }

    fun addObjectsCategory(b: Bromoji) {
        bromojiObjects.add(b)
    }

    fun addSymbolsCategory(b: Bromoji) {
        bromojiSymbols.add(b)
    }

    fun addFlagsCategory(b: Bromoji) {
        bromojiFlags.add(b)
    }

    fun fillRemainingSpaces() {
        val b = Bromoji(arrayOf(), "", "", "")
        while ((bromojiFirstKeyboard.size % 8) != 0) {
            addMostUsed(b)
        }
        while ((bromojiPeople.size % 8) != 0) {
            addPeopleCategory(b)
        }
        while ((bromojiAnimals.size % 8) != 0) {
            addAnimalsCategory(b)
        }
        while ((bromojiFood.size % 8) != 0) {
            addFoodCategory(b)
        }
        while ((bromojiSports.size % 8) != 0) {
            addSportsCategory(b)
        }
        while ((bromojiTravel.size % 8) != 0) {
            addTravelCategory(b)
        }
        while ((bromojiObjects.size % 8) != 0) {
            addObjectsCategory(b)
        }
        while ((bromojiSymbols.size % 8) != 0) {
            addSymbolsCategory(b)
        }
        while ((bromojiFlags.size % 8) != 0) {
            addFlagsCategory(b)
        }
    }
}
