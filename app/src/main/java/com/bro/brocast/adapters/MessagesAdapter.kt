package com.bro.brocast.adapters

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.bro.brocast.R
import com.bro.brocast.objects.Message
import java.util.*


class MessagesAdapter(private var messages: MutableList<Message>)  : RecyclerView.Adapter<MessagesAdapter.MessageViewHolder>() {

    companion object {
        private const val SENT = 0
        private const val RECEIVED = 1
    }

    private var broName: String = "bro"
    private var brosBro: String = "bros bro"

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
        holder.bind(messages[position])
    }

    override fun getItemViewType(position: Int): Int {
        return if (messages[position].sender) {
            SENT
        } else {
            RECEIVED
        }
    }

    fun clearmessages() {
        this.messages.clear()
    }

    fun updateMessages(messages: List<Message>) {
        this.messages = messages.toMutableList()
        notifyDataSetChanged()
    }

    fun appendMessage(message: Message) {
        this.messages.add(message)
        notifyItemInserted(this.messages.size - 1)
    }

    inner class MessageViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView) {
        private val messageText: TextView = itemView.findViewById(R.id.message_text)
        private val timeStampText: TextView = itemView.findViewById(R.id.txtOtherMessageTime)
        private val otherUserText: TextView = itemView.findViewById(R.id.txtOtherUser)

        fun bind(message: Message) {
            messageText.setTextSize(20f)
            messageText.text = message.body
            timeStampText.text = message.timeStamp
            if (message.sender) {
                otherUserText.text = broName
            } else {
                otherUserText.text = brosBro
            }
            // TODO @Skools: possibly expand it here to include pictures and stuff.
        }
    }

    fun setBro(bro: String) {
        broName = bro
    }

    fun setBrosBro(bro: String) {
        brosBro = bro
    }
}