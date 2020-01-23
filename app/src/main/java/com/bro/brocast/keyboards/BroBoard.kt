package com.bro.brocast.keyboards

import android.app.Activity
import android.view.View
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.RelativeLayout
import androidx.fragment.app.FragmentManager
import com.bro.brocast.R
import com.bro.brocast.adapters.BroViewPager
import com.bro.brocast.adapters.PagerBrodapter
import com.bro.brocast.adapters.SlidingTabLayout

class BroBoard(activity: Activity, supportFragmentManager: FragmentManager, broTextField: EditText, questionButton: Button, exclamationButton: Button, backButton: ImageButton) {

    var vpPager: BroViewPager? = null
    var mSlidingTabLayout: SlidingTabLayout? = null
    var extraInputField: RelativeLayout? = null

    var visible: Boolean = true

    init {
        vpPager = activity.findViewById(R.id.vpPager)
        mSlidingTabLayout = activity.findViewById(R.id.sliding_tabs)
        extraInputField = activity.findViewById(R.id.extra_input_field)

        val adapterViewPager = PagerBrodapter(supportFragmentManager)

        // TODO @Skools: We set the pagerBrodapter twice. See if you can fix this.
        vpPager!!.adapter = adapterViewPager
        vpPager!!.pagerBrodapter = adapterViewPager
        adapterViewPager.broTextField = broTextField
        adapterViewPager.extraInputField = extraInputField

        adapterViewPager.questionButton = questionButton
        adapterViewPager.exclamationButton = exclamationButton
        adapterViewPager.backButton = backButton

        val iconArray = arrayOf(
            R.drawable.tab_most_used,
            R.drawable.tab_smile,
            R.drawable.tab_animals,
            R.drawable.tab_food,
            R.drawable.tab_sports,
            R.drawable.tab_travel,
            R.drawable.tab_objects,
            R.drawable.tab_symbol,
            R.drawable.tab_flags
        )
        mSlidingTabLayout!!.setTabIcons(iconArray)

        mSlidingTabLayout!!.setDistributeEvenly(true)
        mSlidingTabLayout!!.setViewPager(vpPager)

        vpPager!!.visibility = View.GONE
        mSlidingTabLayout!!.visibility = View.GONE
        extraInputField!!.visibility = View.GONE
        visible = false
    }

    fun goToTabPosition(position: Int) {
        mSlidingTabLayout!!.goToTab()
    }

    fun makeVisible() {
        vpPager!!.visibility = View.VISIBLE
        mSlidingTabLayout!!.visibility = View.VISIBLE
        extraInputField!!.visibility = View.VISIBLE
        visible = true
    }

    fun makeInvisible() {
        vpPager!!.visibility = View.GONE
        mSlidingTabLayout!!.visibility = View.GONE
        extraInputField!!.visibility = View.GONE
        visible = false
    }

}