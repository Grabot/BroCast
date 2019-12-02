package com.bro.brocast

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import com.bro.brocast.objects.Bro
import com.bro.brocast.objects.ExpandableListAdapter
import kotlinx.android.synthetic.main.activity_find_bros2.*


class FindBroTest: AppCompatActivity() {

    val header: MutableList<Bro> = ArrayList()
    val body: MutableList<MutableList<Bro>> = ArrayList()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_find_bros2)

        var season1: MutableList<Bro> = ArrayList()
        var bro1 = Bro("Sander", 0, "")
        season1.add(bro1)


        var season2: MutableList<Bro> = ArrayList()
        var bro2 = Bro("Mark", 1, "")
        season2.add(bro2)

        var season3: MutableList<Bro> = ArrayList()
        var bro3 = Bro("Renee", 2, "")
        season3.add(bro3)

        header.add(bro1)
        header.add(bro2)
        header.add(bro3)

        body.add(season1)
        body.add(season2)
        body.add(season3)

        bro_list_view2.setAdapter(ExpandableListAdapter(this@FindBroTest, bro_list_view2, header, body))
    }

}