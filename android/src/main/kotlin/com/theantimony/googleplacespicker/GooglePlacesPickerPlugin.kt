package com.theantimony.googleplacespicker

//import com.google.android.gms.location.places.ui.PlaceAutocomplete
//import com.google.android.gms.location.places.ui.PlacePicker
//import com.google.android.gms.location.places.AutocompleteFilter
import android.app.Activity
import android.app.Activity.RESULT_CANCELED
import android.app.Activity.RESULT_OK
import android.content.Intent
import com.google.android.gms.common.GooglePlayServicesNotAvailableException
import com.google.android.gms.common.GooglePlayServicesRepairableException
import com.google.android.libraries.places.api.Places
import com.google.android.libraries.places.api.model.Place
import com.google.android.libraries.places.api.model.TypeFilter
import com.google.android.libraries.places.api.net.PlacesClient
import com.google.android.libraries.places.widget.Autocomplete
import com.google.android.libraries.places.widget.AutocompleteActivity
import com.google.android.libraries.places.widget.model.AutocompleteActivityMode
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import java.util.*


class GooglePlacesPickerPlugin() : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    lateinit var mActivity: Activity
    lateinit var mClient: PlacesClient
    var mPendingResult: Result? = null

    companion object {
        val PLACE_PICKER_REQUEST_CODE = 131070
        val PLACE_AUTOCOMPLETE_REQUEST_CODE = 131071

        @JvmStatic
        fun registerWith(registrar: PluginRegistry.Registrar): Unit {
            val channel = MethodChannel(registrar.messenger(), "plugin_google_place_picker")
            val instance = GooglePlacesPickerPlugin().apply {
                mActivity = registrar.activity()
            }
            registrar.addActivityResultListener(instance)
            channel.setMethodCallHandler(instance)
        }
    }


    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method.equals("init")) {
            setPendingResult(result)
            try {
                val apiKey: String = call.argument<String>("apiKey").orEmpty()
                Places.initialize(mActivity.applicationContext, apiKey)
                mClient = Places.createClient(mActivity)
                pendingResultSuccess(null)
            } catch (e: Exception) {
                pendingResultError(e.message ?: "", null, null)
            }
//        } else if (call.method.equals("showPlacePicker")) {
//            showPlacesPicker()
        } else if (call.method.equals("showAutocomplete")) {
            setPendingResult(result)
            showAutocompletePicker(call.argument("mode"), call.argument("country"))
//        } else if (call.method.equals("fetchPlace")) {
//            fetchPlace(call.argument("id"), result)
        } else {
            result.notImplemented()
        }
    }

    private fun setPendingResult(result: Result) {
        if (mPendingResult != null) {
            pendingResultError("Picker in progress", null, null)
        }
        mPendingResult = result
    }

//    private fun fetchPlace(placeId: String?, result: Result) {
//        if (placeId == null) {
//            result.error("placeId cannot be null", null, null)
//            return
//        }
//        val fields = Arrays.asList(Place.Field.ADDRESS, Place.Field.ID, Place.Field.LAT_LNG, Place.Field.NAME, Place.Field.OPENING_HOURS, Place.Field.PHONE_NUMBER, Place.Field.PHOTO_METADATAS, Place.Field.PLUS_CODE, Place.Field.PRICE_LEVEL, Place.Field.RATING, Place.Field.TYPES, Place.Field.USER_RATINGS_TOTAL, Place.Field.VIEWPORT, Place.Field.WEBSITE_URI)
//        mClient.fetchPlace(FetchPlaceRequest.newInstance(placeId, fields)).addOnSuccessListener { response: FetchPlaceResponse ->
//            mPendingResult.success(response.place)
//        }
////            Place place = response.getPlace()
////            Log.i(TAG, "Place found: " + place.getName());
////        ).addOnFailureListener((exception) -> {
////            if (exception instanceof ApiException) {
////                ApiException apiException = (ApiException) exception;
////                int statusCode = apiException.getStatusCode();
////                // Handle error with given status code.
////                Log.e(TAG, "Place not found: " + exception.getMessage());
////            }
////        });
//    }

//    fun showPlacesPicker() {
//        val builder = PlacePicker.IntentBuilder()
//        try {
//            mActivity.startActivityForResult(builder.build(mActivity), PLACE_PICKER_REQUEST_CODE)
//        } catch (e: GooglePlayServicesRepairableException) {
//            pendingResultError("GooglePlayServicesRepairableException", e.message, null)
//        } catch (e: GooglePlayServicesNotAvailableException) {
//            pendingResultError("GooglePlayServicesNotAvailableException", e.message, null)
//        }
//
//
//    }

    private fun showAutocompletePicker(mode: Int?, country: String?) {
        val modeToUse = mode ?: 71
        val activityMode: AutocompleteActivityMode = if (modeToUse == 71) AutocompleteActivityMode.OVERLAY else AutocompleteActivityMode.FULLSCREEN
//        val fields = Arrays.asList(Place.Field.ADDRESS, Place.Field.ID, Place.Field.LAT_LNG, Place.Field.NAME, Place.Field.OPENING_HOURS, Place.Field.PHONE_NUMBER, Place.Field.PHOTO_METADATAS, Place.Field.PLUS_CODE, Place.Field.PRICE_LEVEL, Place.Field.RATING, Place.Field.TYPES, Place.Field.USER_RATINGS_TOTAL, Place.Field.VIEWPORT, Place.Field.WEBSITE_URI)
        val fields = Arrays.asList(Place.Field.ID)
        val builder = Autocomplete.IntentBuilder(activityMode, fields)
                .setTypeFilter(TypeFilter.ADDRESS)
        if (country != null) {
            builder.setCountry(country)
        }
        val intent = builder.build(mActivity)
        try {
            mActivity.startActivityForResult(intent, PLACE_AUTOCOMPLETE_REQUEST_CODE)
        } catch (e: GooglePlayServicesNotAvailableException) {
            pendingResultError("GooglePlayServicesNotAvailableException", e.message, null)
        } catch (e: GooglePlayServicesRepairableException) {
            pendingResultError("GooglePlayServicesRepairableException", e.message, null)
        }

    }

    override fun onActivityResult(p0: Int, p1: Int, p2: Intent?): Boolean {
        if (p1 == RESULT_OK) {
            when (p0) {
//                PLACE_PICKER_REQUEST_CODE -> {
//                    val place = PlacePicker.getPlace(mActivity, p2)
//                    val placeMap = mutableMapOf<String, Any>()
//                    placeMap.put("latitude", place.latLng.latitude.toString() + "")
//                    placeMap.put("longitude", place.latLng.longitude.toString() + "")
//                    placeMap.put("id", place.id)
//                    placeMap.put("name", place.name.toString())
//                    placeMap.put("address", place.address.toString())
//                    mPendingResult?.success(placeMap)
//                    return true
//
//                }
                PLACE_AUTOCOMPLETE_REQUEST_CODE -> {
                    val place: Place = Autocomplete.getPlaceFromIntent(p2!!)
                    val placeMap = mutableMapOf<String, Any?>()
//                    placeMap.put("latitude", place.latLng?.latitude)
//                    placeMap.put("longitude", place.latLng?.longitude)
                    placeMap.put("id", place.id)
//                    placeMap.put("name", place.name.toString())
//                    placeMap.put("address", place.address.toString())
                    mPendingResult?.success(placeMap)
                    return true
//                    val place = PlaceAutocomplete.getPlace(mActivity, p2)
//                    val placeMap = mutableMapOf<String, Any>()
//                    placeMap.put("latitude", place.latLng.latitude)
//                    placeMap.put("longitude", place.latLng.longitude)
//                    placeMap.put("id", place.id)
//                    placeMap.put("name", place.name.toString())
//                    placeMap.put("address", place.address.toString())
//                    mPendingResult?.success(placeMap)
//                    return true
                }
            }
        } else if (p1 == AutocompleteActivity.RESULT_ERROR) {
            val status = Autocomplete.getStatusFromIntent(p2!!)
            pendingResultError("PLACE_AUTOCOMPLETE_ERROR", status.statusMessage, null)
//        } else if (p1 == PlacePicker.RESULT_ERROR) {
//            val status = PlacePicker.getStatus(mActivity, p2)
//            pendingResultError("PLACE_PICKER_ERROR", status.statusMessage, null)
        } else if (p1 == RESULT_CANCELED) {
            pendingResultError("USER_CANCELED", "User has canceled the operation.", null)
        } else {
            pendingResultError("UNKNOWN", "Unknown error.", null)
        }
        return false
    }

    fun pendingResultSuccess(o: Any?) {
        mPendingResult?.success(o)
        mPendingResult = null
    }

    fun pendingResultError(s: String, s1: String?, o: Any?) {
        mPendingResult?.error(s, s1, o)
        mPendingResult = null
    }
}
