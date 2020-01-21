package com.bro.brocast.adapters

import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.RelativeLayout
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.bro.brocast.keyboards.*

class PagerBrodapter(fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    var broTextField: EditText? = null
    var extraInputField: RelativeLayout? = null

    var questionButton: Button? = null
    var exclamationButton: Button? = null
    var backButton: ImageButton? = null

    // Returns total number of pages
    override fun getCount(): Int {
        return NUM_ITEMS
    }

    // Returns the fragment to display for that page
    override fun getItem(position: Int): Fragment {
        when (position) {
            0  -> {
                // TODO @Sander: add a most used keyboard? placeholder for now
                return FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!, extraInputField!!, questionButton!!, exclamationButton!!, backButton!!)
            }
            1 -> {
                return SecondKeyboardFragment.newInstance(1, "Page # 2", broTextField!!)
            }
            2 -> {
                return ThirdKeyboardFragment.newInstance(2, "Page # 3", broTextField!!)
            }
            3 -> {
                return FourthKeyboardFragment.newInstance(3, "Page # 4", broTextField!!)
            }
            4 -> {
                return FifthKeyboardFragment.newInstance(4, "Page # 5", broTextField!!)
            }
            5 -> {
                return SixthsKeyboardFragment.newInstance(5, "Page # 6", broTextField!!)
            }
            6 -> {
                return SeventhKeyboardFragment.newInstance(6, "Page # 7", broTextField!!)
            }
            7 -> {
                return EighthKeyboardFragment.newInstance(7, "Page # 8", broTextField!!)
            }
            8 -> {
                return NinthKeyboardFragment.newInstance(8, "Page # 9", broTextField!!)
            }
            else -> {
                return FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!, extraInputField!!, questionButton!!, exclamationButton!!, backButton!!)
            }
        }
    }

    companion object {
        private val NUM_ITEMS = 9
    }
}