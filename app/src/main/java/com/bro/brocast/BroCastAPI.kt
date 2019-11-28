package com.bro.brocast

import com.google.gson.GsonBuilder
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*

class BroCastAPI {
    interface APIService {

        @GET("/api/v1.0/register/{bro_name}/{password}")
        fun registerUser(
            @Path("bro_name") broName: String,
            @Path("password") password: String): Call<ResponseBody>

        @GET("/api/v1.0/login/{bro_name}/{password}")
        fun loginUser(
            @Path("bro_name") broName: String,
            @Path("password") password: String): Call<ResponseBody>

        @GET("/api/v1.0/search/{bro}")
        fun findBro(
            @Path("bro") bro: String): Call<ResponseBody>

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