package com.bro.brocast.objects

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseExpandableListAdapter
import android.widget.ExpandableListView
import android.widget.TextView
import android.widget.Toast
import com.bro.brocast.R

class ExpandableListAdapter(var context: Context, var expandableListView : ExpandableListView, var header : MutableList<Bro>, var body : MutableList<MutableList<Bro>>) : BaseExpandableListAdapter() {

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
//        val headerText: String = getGroup(groupPosition)

        textView.text = bro.broName

        view.setOnClickListener {
            if(expandableListView.isGroupExpanded(groupPosition))
                expandableListView.collapseGroup(groupPosition)
            else
                expandableListView.expandGroup(groupPosition)
            Toast.makeText(context, getGroup(groupPosition).broName, Toast.LENGTH_SHORT).show()
        }
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
        val title = view?.findViewById<TextView>(R.id.broListClicked)
        title?.text = getChild(groupPosition,childPosition).broName

        title?.setOnClickListener {
            Toast.makeText(context, getChild(groupPosition,childPosition).broName,Toast.LENGTH_SHORT).show()
        }
        return view
    }

    override fun getChildId(groupPosition: Int, childPosition: Int): Long {
        return childPosition.toLong()
    }

    override fun getGroupCount(): Int {
        return header.size
    }
}