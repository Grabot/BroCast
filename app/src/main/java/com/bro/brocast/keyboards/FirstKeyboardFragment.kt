package com.bro.brocast.keyboards

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.Button
import android.widget.EditText
import android.widget.ImageButton
import android.widget.RelativeLayout
import androidx.fragment.app.Fragment
import com.bro.brocast.R


class FirstKeyboardFragment : Fragment() {
    // Store instance variables
    private var title: String? = null
    private var page: Int = 0

    var broTextField: EditText? = null

    var extraInputField: RelativeLayout? = null
    var questionButton: Button? = null
    var exclamationButton: Button? = null
    var backButton: ImageButton? = null

    // Store instance variables based on arguments passed
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        page = arguments!!.getInt("someInt", 0)
        title = arguments!!.getString("someTitle")
    }

    // Inflate the view for the fragment based on layout XML
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.keyboard_1_fragment, container, false)

        val keyboard = view.findViewById(R.id.keyboard) as FirstKeyboard
        keyboard.extraInputField = extraInputField
        keyboard.questionButton = questionButton
        keyboard.exclamationButton = exclamationButton
        keyboard.backButton = backButton
        keyboard.setClickListenerExtraFields()

        val ic = broTextField!!.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)

        return view
    }

    companion object {

        // newInstance constructor for creating fragment with arguments
        // We added the editText here that the focus of the keyboard should be on.
        fun newInstance(page: Int, title: String, broTextField: EditText, extraInputField: RelativeLayout, questionButton: Button, exclamationButton: Button, backButton: ImageButton): FirstKeyboardFragment {
            val fragment = FirstKeyboardFragment()
            fragment.broTextField = broTextField
            fragment.extraInputField = extraInputField
            fragment.questionButton = questionButton
            fragment.exclamationButton = exclamationButton
            fragment.backButton = backButton
            val args = Bundle()
            args.putInt("someInt", page)
            args.putString("someTitle", title)
            fragment.arguments = args
            return fragment
        }
    }
}