package com.bro.brocast.adapters

import android.content.Context
import android.graphics.Typeface
import android.os.Build
import android.util.AttributeSet
import android.util.SparseArray
import android.util.TypedValue
import android.view.Gravity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.HorizontalScrollView
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.viewpager.widget.ViewPager
import com.bro.brocast.R

class SlidingTabLayoutNew: HorizontalScrollView {

    interface TabColorizer {

        /**
         * @return return the color of the indicator used when `position` is selected.
         */
        fun getIndicatorColor(position: Int): Int
    }

    private val TITLE_OFFSET_DIPS = 24
    private val TAB_VIEW_PADDING_DIPS = 16
    private val TAB_VIEW_TEXT_SIZE_SP = 12

    private var mTitleOffset: Int = 0

    private var mTabStrip: SlidingTabStrip? = null

    private var mDistributeEvenly: Boolean = false

    private var mTabViewLayoutId: Int = 0
    private var mTabViewTextViewId: Int = 0

    private var mViewPagerPageChangeListener: ViewPager.OnPageChangeListener? = null
    private val mContentDescriptions = SparseArray<String>()

    // This is used to store the tab icons
    private var tabIcon: Array<Int>? = null

    var NUM_ITEMS = 0

    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        init(context)
    }

    fun init(context: Context) {
        // Initialize the NUM_ITEMS. This is the amount of tabs that the user can click on
        NUM_ITEMS = 0
        // Disable the Scroll Bar
        isHorizontalScrollBarEnabled = false
        // Make sure that the Tab Strips fills this View
        isFillViewport = true

        mTitleOffset = (TITLE_OFFSET_DIPS * resources.displayMetrics.density).toInt()
        mTabStrip = SlidingTabStrip(context)
        addView(
            mTabStrip,
            LayoutParams.MATCH_PARENT,
            LayoutParams.WRAP_CONTENT
        )
    }

    fun setDistributeEvenly(distributeEvenly: Boolean) {
        mDistributeEvenly = distributeEvenly
    }

    fun populateTabStrip() {
        val tabClickListener = TabClickListener()

        for (i in 0 until NUM_ITEMS) {
            var tabView: View? = null
            var tabTitleView: TextView? = null

            if (mTabViewLayoutId != 0) {
                // If there is a custom tab view layout id set, try and inflate it
                tabView = LayoutInflater.from(context).inflate(
                    mTabViewLayoutId, mTabStrip,
                    false
                )
                tabTitleView = tabView.findViewById<View>(mTabViewTextViewId) as TextView
            }

            if (tabView == null) {
                tabView = createDefaultTabView(context)
            }

            if (tabTitleView == null && TextView::class.java.isInstance(tabView)) {
                tabTitleView = tabView as TextView?
            }

            tabView = LayoutInflater.from(context).inflate(
                R.layout.keyboard_custom_tab,
                mTabStrip, false
            )

            val iconImageView = tabView.findViewById<ImageView>(R.id.keyboard_custom_tab_image)
            iconImageView.setImageDrawable(context.resources.getDrawable(tabIcon!![i], null))

            if (mDistributeEvenly) {
                val lp = tabView.layoutParams as LinearLayout.LayoutParams
                lp.width = 0
                lp.weight = 1f
            }

            // TODO @Skools: find out if this has any use
            tabTitleView!!.text = "text?"
            tabView.setOnClickListener(tabClickListener)
            val desc = mContentDescriptions.get(i, null)
            if (desc != null) {
                tabView.contentDescription = desc
            }

            mTabStrip!!.addView(tabView)
            // TODO @Skools: find out if this has any use
            if (i == 0) {
                tabView.isSelected = true
            }
        }
    }

    private fun scrollToTab(tabIndex: Int, positionOffset: Int) {
        val tabStripChildCount = mTabStrip!!.childCount
        if (tabStripChildCount == 0 || tabIndex < 0 || tabIndex >= tabStripChildCount) {
            return
        }

        val selectedChild = mTabStrip!!.getChildAt(tabIndex)
        if (selectedChild != null) {
            var targetScrollX = selectedChild.left + positionOffset

            if (tabIndex > 0 || positionOffset > 0) {
                // If we're not at the first child and are mid-scroll, make sure we obey the offset
                targetScrollX -= mTitleOffset
            }

            scrollTo(targetScrollX, 0)
        }
    }

    fun pageSelected(position: Int) {
        println("This is the 'onPageSelected' function. position $position")
        for (i in 0 until mTabStrip!!.childCount) {
            mTabStrip!!.getChildAt(i).isSelected = position == i
        }
        if (mViewPagerPageChangeListener != null) {
            mViewPagerPageChangeListener!!.onPageSelected(position)
        }
    }

    fun pageScrolled(position: Int, positionOffset: Float, positionOffsetPixels: Int) {

        println("This is the 'onPageScrolled' function. position $position positionOffset $positionOffset positionOffsetPixels $positionOffsetPixels")
        val tabStripChildCount = mTabStrip!!.childCount
        if (tabStripChildCount == 0 || position < 0 || position >= tabStripChildCount) {
            return
        }

        mTabStrip!!.onViewPagerPageChanged(position, positionOffset)

        val selectedTitle = mTabStrip!!.getChildAt(position)
        var extraOffset = 0
        if (selectedTitle != null) {
            extraOffset = (positionOffset * selectedTitle.width).toInt()
        }
        scrollToTab(position, extraOffset)

        if (mViewPagerPageChangeListener != null) {
            mViewPagerPageChangeListener!!.onPageScrolled(
                position, positionOffset,
                positionOffsetPixels
            )
        }
    }

    fun goToTab(position: Int, positionOffset: Float) {
        // copy paste of tab 0 to tab 4
        pageSelected(position)
        pageScrolled(position, positionOffset, 0)
    }

    /**
     * Create a default view to be used for tabs. This is called if a custom tab view is not set via
     * [.setCustomTabView].
     */
    private fun createDefaultTabView(context: Context): TextView {
        val textView = TextView(context)
        textView.gravity = Gravity.CENTER
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, TAB_VIEW_TEXT_SIZE_SP.toFloat())
        textView.typeface = Typeface.DEFAULT_BOLD
        textView.layoutParams = LinearLayout.LayoutParams(
            ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT
        )

        val outValue = TypedValue()
        getContext().theme.resolveAttribute(
            android.R.attr.selectableItemBackground,
            outValue, true
        )
        textView.setBackgroundResource(outValue.resourceId)
        textView.isAllCaps = true

        val padding = (TAB_VIEW_PADDING_DIPS * resources.displayMetrics.density).toInt()
        textView.setPadding(padding, padding, padding, padding)

        return textView
    }

    private inner class TabClickListener : OnClickListener {
        override fun onClick(v: View) {
            for (i in 0 until mTabStrip!!.childCount) {
                if (v === mTabStrip!!.getChildAt(i)) {
                    goToTab(i, 0f)
                    return
                }
            }
        }
    }

    fun setTabIcons(tabIcon: Array<Int>) {
        NUM_ITEMS = tabIcon.size
        this.tabIcon = tabIcon
    }
}