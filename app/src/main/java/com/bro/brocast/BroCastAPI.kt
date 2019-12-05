package com.bro.brocast

import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import retrofit2.http.GET
import retrofit2.http.Path
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

    }

    companion object {

        // This allows us to set a timeout. We don't want to wait a long time for a server response.
        val okHttpClient = OkHttpClient.Builder()
            .readTimeout(2, TimeUnit.SECONDS)
            .connectTimeout(2, TimeUnit.SECONDS)
            .build()

        private val retrofit = Retrofit.Builder()
            .baseUrl(brocastURLHome)
            .addConverterFactory(GsonConverterFactory.create(GsonBuilder().create()))
            .client(okHttpClient)
            .build()

        var service = retrofit.create(APIService::class.java)
    }
}