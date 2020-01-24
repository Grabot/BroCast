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
            else -> {
                // TODO @Skools: Change this to be a normal scrollview
                return FirstKeyboardFragment.newInstance(
                    0,
                    "Page # 1",
                    broTextField!!,
                    extraInputField!!,
                    questionButton!!,
                    exclamationButton!!,
                    backButton!!
                )
            }
        }
    }

    companion object {
        private val NUM_ITEMS = 9
    }
}