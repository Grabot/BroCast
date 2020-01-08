package com.bro.brocast.adapters

import android.widget.EditText
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentPagerAdapter
import com.bro.brocast.keyboards.FirstKeyboardFragment
import com.bro.brocast.keyboards.SecondKeyboardFragment

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
                var first = FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!)
                return first
            }
            1 -> {
                var second = SecondKeyboardFragment.newInstance(1, "Page # 2", broTextField!!)
                return second
            }
            2 -> {
                var third = FirstKeyboardFragment.newInstance(2, "Page # 3", broTextField!!)
                return third
            }
            else -> {
                var first = FirstKeyboardFragment.newInstance(0, "Page # 1", broTextField!!)
                return first
            }
        }
    }

    // Returns the page title for the top indicator
    override fun getPageTitle(position: Int): CharSequence? {
        return "Page $position"
    }

    companion object {
        private val NUM_ITEMS = 3
    }
}