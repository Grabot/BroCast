package com.bro.brocast

import com.google.gson.GsonBuilder
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*

class BroCastAPI {
    interface APIService {
        @GET("/test")
        fun getTest(): Call<ResponseBody>

        @GET("/api/v1.0/register/{username}/{password}")
        fun registerUser(
            @Path("username") username: String,
            @Path("password") password: String): Call<ResponseBody>
    }

    companion object {
        // The URL is how to get from the android emulator the the localhost on the computer.
        private val retrofit = Retrofit.Builder()
            .baseUrl("http://10.0.2.2:5000")
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .build()

        var service = retrofit.create(APIService::class.java)
    }
}