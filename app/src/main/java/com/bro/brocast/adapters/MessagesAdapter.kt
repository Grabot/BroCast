package com.bro.brocast.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bro.brocast.R
import com.bro.brocast.objects.Message

class MessagesAdapter(private var messages: MutableList<Message>)  : RecyclerView.Adapter<MessagesAdapter.MessageViewHolder>() {

    companion object {
        private const val SENT = 0
        private const val RECEIVED = 1
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): MessageViewHolder {
        val view = when (viewType) {
            SENT -> {
                LayoutInflater.from(parent.context).inflate(R.layout.bro_message_send, parent, false)
            }
            else -> {
                LayoutInflater.from(parent.context).inflate(R.layout.bro_message_received, parent, false)
            }
        }
        return MessageViewHolder(view)
    }

    override fun getItemCount() = messages.size

    override fun onBindViewHolder(holder: MessageViewHolder, position: Int) {
        holder.bind(messages[position].body)
    }

    override fun getItemViewType(position: Int): Int {
        return if (messages[position].sender) {
            SENT
        } else {
            RECEIVED
        }
    }

    inner class MessageViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val messageText: TextView = itemView.findViewById(R.id.message_text)

        fun bind(message: String) {
            messageText.text = message
            // TODO @Skools: possibly expand it here to include pictures and stuff.
        }
    }
}