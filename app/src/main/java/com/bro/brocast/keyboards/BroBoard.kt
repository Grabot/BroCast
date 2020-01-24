package com.bro.brocast.keyboards

import android.app.Activity
import android.view.View
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.RelativeLayout
import androidx.fragment.app.FragmentManager
import com.bro.brocast.R
import com.bro.brocast.adapters.SlidingTabLayoutNew

class BroBoard(activity: Activity, broTextField: EditText, questionButton: Button, exclamationButton: Button, backButton: ImageButton) {

    var keyboardTest: FirstKeyboard = activity.findViewById(R.id.keyboard_test)
    var mSlidingTabLayout: SlidingTabLayoutNew = activity.findViewById(R.id.sliding_tabs)
    var extraInputField: RelativeLayout = activity.findViewById(R.id.extra_input_field)

    var visible: Boolean = true

    init {
        keyboardTest.exclamationButton = exclamationButton
        keyboardTest.questionButton = questionButton
        keyboardTest.backButton = backButton
        keyboardTest.extraInputField = extraInputField
        keyboardTest.setClickListenerExtraFields()

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

        keyboardTest.visibility = View.GONE
        mSlidingTabLayout.visibility = View.GONE
        extraInputField.visibility = View.GONE
        visible = false

        val ic = broTextField.onCreateInputConnection(EditorInfo())
        keyboardTest.setInputConnection(ic)

    }

    fun goToTabPosition(position: Int) {
        mSlidingTabLayout.goToTab(position, 0f)
    }

    fun makeVisible() {
        keyboardTest.visibility = View.VISIBLE
        mSlidingTabLayout.visibility = View.VISIBLE
        extraInputField.visibility = View.VISIBLE
        visible = true
    }

    fun makeInvisible() {
        keyboardTest.visibility = View.GONE
        mSlidingTabLayout.visibility = View.GONE
        extraInputField.visibility = View.GONE
        visible = false
    }

}