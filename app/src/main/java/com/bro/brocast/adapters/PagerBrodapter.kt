package com.bro.brocast.adapters

import android.widget.EditText
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.bro.brocast.keyboards.FirstKeyboardFragment
import com.bro.brocast.keyboards.FourthKeyboardFragment
import com.bro.brocast.keyboards.SecondKeyboardFragment
import com.bro.brocast.keyboards.ThirdKeyboardFragment

class PagerBrodapter(fragmentManager: FragmentManager) : FragmentPagerAdapter(fragmentManager) {

    var broTextField: EditText? = null

    // Returns total number of pages
    override fun getCount(): Int {
        return NUM_ITEMS
    }

    // Returns the fragment to display for that page
    override fun getItem(position: Int): Fragment {
        when (position) {
            0  -> {
                return FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!)
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
            else -> {
                return FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!)
            }
        }
    }

    companion object {
        private val NUM_ITEMS = 4
    }
}