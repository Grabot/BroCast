package com.bro.brocast

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.widget.EditText
import androidx.fragment.app.Fragment
import com.bro.brocast.objects.MyKeyboard


class FirstFragment : Fragment() {
    // Store instance variables
    private var title: String? = null
    private var page: Int = 0

    var broTextField: EditText? = null

    // Store instance variables based on arguments passed
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        page = arguments!!.getInt("someInt", 0)
        title = arguments!!.getString("someTitle")
    }

    // Inflate the view for the fragment based on layout XML
    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View? {
        val view = inflater.inflate(R.layout.fragment_first, container, false)
        val keyboard = view.findViewById(R.id.keyboard) as MyKeyboard

        val ic = broTextField!!.onCreateInputConnection(EditorInfo())
        keyboard.setInputConnection(ic)

        return view
    }

    companion object {

        // newInstance constructor for creating fragment with arguments
        // We added the editText here that the focus of the keyboard should be on.
        fun newInstance(page: Int, title: String, broTextField: EditText): FirstFragment {
            val fragmentFirst = FirstFragment()
            fragmentFirst.broTextField = broTextField
            val args = Bundle()
            args.putInt("someInt", page)
            args.putString("someTitle", title)
            fragmentFirst.arguments = args
            return fragmentFirst
        }
    }
}