package com.bro.brocast.adapters

import android.content.Context
import android.graphics.Typeface
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

class SlidingTabLayout: HorizontalScrollView {

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

    private var mViewPager: BroViewPager? = null
    private var mTabViewLayoutId: Int = 0
    private var mTabViewTextViewId: Int = 0

    private var mViewPagerPageChangeListener: ViewPager.OnPageChangeListener? = null
    private val mContentDescriptions = SparseArray<String>()

    // This is used to store the tab icons
    private var tabIcon: Array<Int>? = null


    constructor(context: Context) : super(context) {
        init(context)
    }

    constructor(context: Context, attrs: AttributeSet) : super(context, attrs) {
        init(context)
    }

    fun init(context: Context) {
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

    /**
     * Set the [ViewPager.OnPageChangeListener]. When using [SlidingTabLayout] you are
     * required to set any [ViewPager.OnPageChangeListener] through this method. This is so
     * that the layout can update it's scroll position correctly.
     *
     * @see ViewPager.setOnPageChangeListener
     */
    fun setOnPageChangeListener(listener: ViewPager.OnPageChangeListener) {
        mViewPagerPageChangeListener = listener
    }

    fun setDistributeEvenly(distributeEvenly: Boolean) {
        mDistributeEvenly = distributeEvenly
    }

    /**
     * Sets the associated view pager. Note that the assumption here is that the pager content
     * (number of tabs and tab titles) does not change after this call has been made.
     */
    fun setViewPager(viewPager: BroViewPager?) {
        mTabStrip!!.removeAllViews()

        mViewPager = viewPager
        if (viewPager != null) {
            viewPager.setOnPageChangeListener(InternalViewPagerListener())
            populateTabStrip()
        }
    }

    private fun populateTabStrip() {
        val adapter = mViewPager!!.pagerBrodapter
        val tabClickListener = TabClickListener()

        // TODO @Skools: Here you set a count for the adapter. this could be fixed if it doesn't work
        for (i in 0 until adapter!!.getCount()) {
            var tabView: View? = null
            var tabTitleView: TextView? = null

            if (mTabViewLayoutId != 0) {
                // If there is a custom tab view layout id set, try and inflate it
                tabView = LayoutInflater.from(context).inflate(
                    mTabViewLayoutId, mTabStrip,
                    false
                )
                tabTitleView = tabView!!.findViewById<View>(mTabViewTextViewId) as TextView
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

            val iconImageView = tabView!!.findViewById<ImageView>(R.id.keyboard_custom_tab_image)
            iconImageView.setImageDrawable(context.resources.getDrawable(tabIcon!![i]))

            if (mDistributeEvenly) {
                val lp = tabView.layoutParams as LinearLayout.LayoutParams
                lp.width = 0
                lp.weight = 1f
            }

            tabTitleView!!.setText(adapter!!.getPageTitle(i))
            tabView.setOnClickListener(tabClickListener)
            val desc = mContentDescriptions.get(i, null)
            if (desc != null) {
                tabView.contentDescription = desc
            }

            mTabStrip!!.addView(tabView)
            if (i == mViewPager!!.getCurrentItem()) {
                tabView.isSelected = true
            }
        }
    }

    private fun scrollToTab(tabIndex: Int, positionOffset: Int) {
        val tabStripChildCount = mTabStrip!!.getChildCount()
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

    private inner class InternalViewPagerListener : ViewPager.OnPageChangeListener {
        private var mScrollState: Int = 0

        override fun onPageScrolled(
            position: Int,
            positionOffset: Float,
            positionOffsetPixels: Int
        ) {
            val tabStripChildCount = mTabStrip!!.getChildCount()
            if (tabStripChildCount == 0 || position < 0 || position >= tabStripChildCount) {
                return
            }

            mTabStrip!!.onViewPagerPageChanged(position, positionOffset)

            val selectedTitle = mTabStrip!!.getChildAt(position)
            val extraOffset = if (selectedTitle != null)
                (positionOffset * selectedTitle.width).toInt()
            else
                0
            scrollToTab(position, extraOffset)

            if (mViewPagerPageChangeListener != null) {
                mViewPagerPageChangeListener!!.onPageScrolled(
                    position, positionOffset,
                    positionOffsetPixels
                )
            }
        }

        override fun onPageScrollStateChanged(state: Int) {
            mScrollState = state

            if (mViewPagerPageChangeListener != null) {
                mViewPagerPageChangeListener!!.onPageScrollStateChanged(state)
            }
        }

        override fun onPageSelected(position: Int) {
            if (mScrollState == ViewPager.SCROLL_STATE_IDLE) {
                mTabStrip!!.onViewPagerPageChanged(position, 0f)
                scrollToTab(position, 0)
            }
            for (i in 0 until mTabStrip!!.getChildCount()) {
                mTabStrip!!.getChildAt(i).isSelected = position == i
            }
            if (mViewPagerPageChangeListener != null) {
                mViewPagerPageChangeListener!!.onPageSelected(position)
            }
        }

    }

    /**
     * Create a default view to be used for tabs. This is called if a custom tab view is not set via
     * [.setCustomTabView].
     */
    protected fun createDefaultTabView(context: Context): TextView {
        val textView = TextView(context)
        textView.gravity = Gravity.CENTER
        textView.setTextSize(TypedValue.COMPLEX_UNIT_SP, TAB_VIEW_TEXT_SIZE_SP.toFloat())
        textView.setTypeface(Typeface.DEFAULT_BOLD)
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

    private inner class TabClickListener : View.OnClickListener {
        override fun onClick(v: View) {
            for (i in 0 until mTabStrip!!.getChildCount()) {
                if (v === mTabStrip!!.getChildAt(i)) {
                    mViewPager!!.setCurrentItem(i)
                    return
                }
            }
        }
    }

    fun setTabIcons(tabIcon: Array<Int>) {
        this.tabIcon = tabIcon
    }
}