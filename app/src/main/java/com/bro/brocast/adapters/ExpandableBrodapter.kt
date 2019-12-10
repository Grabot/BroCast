package com.bro.brocast.adapters

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseExpandableListAdapter
import android.widget.ExpandableListView
import android.widget.TextView
import com.bro.brocast.R
import com.bro.brocast.objects.Bro

class ExpandableBrodapter(var context: Context, var expandableListView : ExpandableListView, var header : ArrayList<Bro>, var body : ArrayList<ArrayList<Bro>>) : BaseExpandableListAdapter() {

    override fun getGroup(groupPosition: Int): Bro {
        return header[groupPosition]
    }

    override fun isChildSelectable(groupPosition: Int, childPosition: Int): Boolean {
        return true
    }

    override fun hasStableIds(): Boolean {
        return false
    }

    override fun getGroupView(
        groupPosition: Int,
        isExpanded: Boolean,
        convertView: View?,
        parent: ViewGroup?
    ): View? {
        var view: View? = convertView

        if (view == null) {
            val layoutInflater: LayoutInflater = LayoutInflater.from(context)
            // We will just assume that this always holds.
            view = layoutInflater.inflate(R.layout.bro_list, parent, false)
        }

        val textView: TextView = view!!.findViewById(R.id.broListBroName)

        val bro: Bro = getGroup(groupPosition)

        textView.text = bro.broName

        return view
    }

    override fun getChildrenCount(groupPosition: Int): Int {
        return body[groupPosition].size
    }

    override fun getChild(groupPosition: Int, childPosition: Int): Bro {
        return body[groupPosition][childPosition]
    }

    override fun getGroupId(groupPosition: Int): Long {
        return groupPosition.toLong()
    }

    override fun getChildView(
        groupPosition: Int,
        childPosition: Int,
        isLastChild: Boolean,
        convertView: View?,
        parent: ViewGroup?
    ): View? {
        var view: View? = convertView
        if(view == null){
            val layoutInflater: LayoutInflater = LayoutInflater.from(context)
            view = layoutInflater.inflate(R.layout.bro_list_click, parent, false)
        }
        val add_bro = view?.findViewById<TextView>(R.id.broListClicked)
        add_bro?.text = "Add bro " + getChild(groupPosition,childPosition).broName

        return view
    }

    override fun getChildId(groupPosition: Int, childPosition: Int): Long {
        return childPosition.toLong()
    }

    override fun getGroupCount(): Int {
        return header.size
    }
}