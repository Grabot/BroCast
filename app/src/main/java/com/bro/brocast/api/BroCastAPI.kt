package com.bro.brocast.api

import com.beust.klaxon.JsonObject
import com.bro.brocast.brocastURL
import com.bro.brocast.brocastURLHome
import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.*
import java.util.concurrent.TimeUnit


class BroCastAPI {
    interface APIService {

        @GET("/api/v1.0/register/{bro_name}/{password}")
        fun registerBro(
            @Path("bro_name") broName: String,
            @Path("password") password: String): Call<ResponseBody>

        @GET("/api/v1.0/login/{bro_name}/{password}")
        fun loginBro(
            @Path("bro_name") broName: String,
            @Path("password") password: String): Call<ResponseBody>

        @GET("/api/v1.0/search/{bro}")
        fun findBro(
            @Path("bro") bro: String): Call<ResponseBody>

        @GET("/api/v1.0/add/{bro}/{bros_bro}")
        fun addBro(
            @Path("bro") bro: String,
            @Path("bros_bro") brosBro: String): Call<ResponseBody>

        @GET("/api/v1.0/get/bros/{bro}")
        fun getBros(
            @Path("bro") bro: String): Call<ResponseBody>

        // The URL's are the same for the next 2 functions. The first is a get and the other a post.
        @GET("/api/v1.0/message/{bro}/{bros_bro}/{page}")
        fun getMessages(
            @Path("bro") bro: String,
            @Path("bros_bro") brosBro: String,
            @Path("page") page: Int): Call<ResponseBody>

        @Headers("Content-type: application/json")
        @POST("/api/v1.0/message/{bro}/{bros_bro}/{page}")
        fun sendMessage(
            @Path("bro") bro: String,
            @Path("bros_bro") brosBro: String,
            @Path("page") page: Int,
            @Body body: JsonObject): Call<ResponseBody>

    }

    companion object {

        // This allows us to set a timeout. We don't want to wait a long time for a server response.
        val okHttpClient = OkHttpClient.Builder()
            .readTimeout(10, TimeUnit.SECONDS)
            .connectTimeout(10, TimeUnit.SECONDS)
            .build()

        private val retrofit = Retrofit.Builder()
            .baseUrl(brocastURLHome)
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .client(okHttpClient)
            .build()

        var service = retrofit.create(APIService::class.java)
    }
}