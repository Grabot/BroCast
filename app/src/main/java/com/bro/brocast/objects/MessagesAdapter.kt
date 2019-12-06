package com.bro.brocast.objects

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bro.brocast.R

class MessagesAdapter(private val uid: String,
                      private var messages: MutableList<String>)  : RecyclerView.Adapter<MessagesAdapter.MessageViewHolder>() {

    companion object {
        private const val SENT = 0
        private const val RECEIVED = 1
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MessageViewHolder {
        val view = when (viewType) {
            SENT -> {
                println("send?")
                LayoutInflater.from(parent.context).inflate(R.layout.bro_message_send, parent, false)
            }
            else -> {
                println("received?")
                LayoutInflater.from(parent.context).inflate(R.layout.bro_message_received, parent, false)
            }
        }
        return MessageViewHolder(view)
    }

    override fun getItemCount() = messages.size

    override fun onBindViewHolder(holder: MessageViewHolder, position: Int) {
        holder.bind(messages[position])
    }

    override fun getItemViewType(position: Int): Int {
        if (position % 2 == 0) {
            println("received on position $position")
            return RECEIVED
        } else {
            println("send on position $position")
            return SENT
        }
//        return if (messages[position].sender?.uid!!.contentEquals(uid )) {
//            SENT
//        } else {
//            RECEIVED
//        }
    }

    fun updateMessages(messages: List<String>) {
        this.messages = messages.toMutableList()
        notifyDataSetChanged()
    }

    fun appendMessage(message: String) {
        this.messages.add(message)
        notifyItemInserted(this.messages.size - 1)
    }

    inner class MessageViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val messageText: TextView = itemView.findViewById(R.id.message_text)

        fun bind(message: String) {
            println("message: $message")
            messageText.text = message
//            if (message is TextMessage) {
//                messageText.text = message.text
//            }
        }
    }
}