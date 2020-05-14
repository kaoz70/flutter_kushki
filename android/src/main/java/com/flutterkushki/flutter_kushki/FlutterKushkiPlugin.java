package com.flutterkushki.flutter_kushki;

import android.os.Build;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import com.flutterkushki.flutter_kushki.tasks.GetToken;
import com.kushkipagos.android.Card;
import com.kushkipagos.android.Kushki;
import com.kushkipagos.android.KushkiEnvironment;

import java.util.Objects;

/** FlutterKushkiPlugin */
@RequiresApi(api = Build.VERSION_CODES.KITKAT)
public class FlutterKushkiPlugin implements FlutterPlugin, MethodCallHandler {
  static private Kushki kushki;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    final MethodChannel channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "flutter_kushki");
    channel.setMethodCallHandler(new FlutterKushkiPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_kushki");
    channel.setMethodCallHandler(new FlutterKushkiPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("init")) {
      try {
        kushki = init(call);
        result.success(true);
      } catch (Exception e) {
        System.out.println(e.getMessage());
        result.error("init_error", e.getMessage(), call.arguments);
      }
    } else if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else if (call.method.equals("requestToken")) {
      try {
        requestToken(call, result);
      } catch (Exception e) {
        System.out.println(e.toString());
        result.error("exception", e.getMessage(), call.arguments);
      }
    } else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
  }

  private Kushki init(MethodCall call) throws Exception {
    String publicMerchantId = call.argument("publicMerchantId");
    String currency = call.argument("currency");
    KushkiEnvironment environment = KushkiEnvironment.valueOf(Objects.requireNonNull(call.argument("environment")).toString());
    Boolean regional = call.argument("regional");

    if (publicMerchantId == null || publicMerchantId.equals("")) {
      throw new Exception("'publicMerchantId' is required");
    } else if (currency == null || currency.equals("")) {
      throw new Exception("'currency' is required");
    } else if (regional == null) {
      throw new Exception("'regional' is required");
    }

    return new Kushki(publicMerchantId, currency, environment, regional);
  }

  private void requestToken(MethodCall call, final Result result) throws Exception {
    final String name = call.argument("name");
    final String number = call.argument("number");
    final String cvv = call.argument("cvv");
    final String expiryMonth = call.argument("expiryMonth");
    final String expiryYear = call.argument("expiryYear");
    final Double totalAmount = call.argument("totalAmount");

    if (name == null || name.equals("")) {
      throw new Exception("'name' is required");
    } else if (number == null || number.equals("")) {
      throw new Exception("'number' is required");
    } else if (cvv == null || cvv.equals("")) {
      throw new Exception("'cvv' is required");
    } else if (expiryMonth == null || expiryMonth.equals("")) {
      throw new Exception("'expiryMonth' is required");
    } else if (expiryYear == null || expiryYear.equals("")) {
      throw new Exception("'expiryYear' is required");
    } else if (totalAmount == null) {
      throw new Exception("'totalAmount' is required");
    }

    final Card card = new Card(name, number, cvv, expiryMonth, expiryYear);

    new GetToken(kushki, totalAmount, result).execute(card);
  }
}
