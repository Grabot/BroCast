package com.bro.brocast.keyboards

import android.app.Activity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.RelativeLayout
import com.bro.brocast.R
import com.bro.brocast.adapters.SlidingTabLayout

class BroBoard(activity: Activity, broTextField: EditText, questionButton: Button, exclamationButton: Button, backButton: ImageButton) {

    var keyboard: Keyboard = activity.findViewById(R.id.bro_board)
    var mSlidingTabLayout: SlidingTabLayout = activity.findViewById(R.id.sliding_tabs)
    var extraInputField: RelativeLayout = activity.findViewById(R.id.extra_input_field)

    var visible: Boolean = true

    init {
        keyboard.exclamationButton = exclamationButton
        keyboard.questionButton = questionButton
        keyboard.backButton = backButton
        keyboard.extraInputField = extraInputField
        keyboard.setClickListenerExtraFields()
        keyboard.setBroBoard(this)

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
        mSlidingTabLayout.setTabIcons(iconArray)

        mSlidingTabLayout.setDistributeEvenly(true)
        mSlidingTabLayout.populateTabStrip()
        mSlidingTabLayout.setBroBoard(this)

        keyboard.visibility = View.GONE
        mSlidingTabLayout.visibility = View.GONE
        extraInputField.visibility = View.GONE
        visible = false

        val ic = broTextField.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)

    }

    fun goToTabPosition(position: Int, positionOffset: Float) {
        if (position >= 0 && positionOffset >= 0) {
            mSlidingTabLayout.goToTab(position, positionOffset)
        }
    }

    fun goToEmojiCategory(position: Int) {
        // We call this function istead of the tab function because we want to move the scrollview
        // in the scrollview we will move the tab once the position is determined.
        keyboard.goToEmojiCategory(position)
    }

    fun makeVisible() {
        keyboard.visibility = View.VISIBLE
        mSlidingTabLayout.visibility = View.VISIBLE
        extraInputField.visibility = View.VISIBLE
        visible = true
    }

    fun makeInvisible() {
        keyboard.visibility = View.GONE
        mSlidingTabLayout.visibility = View.GONE
        extraInputField.visibility = View.GONE
        visible = false
    }

}